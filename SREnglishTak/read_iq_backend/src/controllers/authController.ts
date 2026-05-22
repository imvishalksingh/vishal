import { type Request, type Response } from 'express';
import { supabase, supabaseAdmin } from '../config/supabase.js';
import { OAuth2Client } from 'google-auth-library';

const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

export class AuthController {
    static async register(req: Request, res: Response) {
        try {
            const { email, password, full_name, admin_secret } = req.body;

            if (!email || !password || !full_name) {
                return res.status(400).json({ error: 'Missing required fields' });
            }

            const isTargetAdmin = admin_secret === process.env.ADMIN_REGISTRATION_SECRET;

            const { data, error } = await supabase.auth.signUp({ email, password });

            if (error) {
                return res.status(400).json({ error: error.message });
            }

            if (data.user) {
                const { error: profileError } = await supabaseAdmin
                    .from('profiles')
                    .insert({
                        id: data.user.id,
                        email,
                        full_name,
                        role: isTargetAdmin ? 'admin' : 'user',
                    });

                if (profileError) {
                    console.error('Profile creation error:', profileError);
                }
            }

            const emailConfirmed = data.session !== null;
            res.status(201).json({
                message: 'User registered successfully',
                email_confirmed: emailConfirmed,
                user: data.user,
                session: data.session,
            });
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async login(req: Request, res: Response) {
        try {
            const { email, password } = req.body;

            if (!email || !password) {
                return res.status(400).json({ error: 'Email and password are required' });
            }

            const { data, error } = await supabase.auth.signInWithPassword({ email, password });

            if (error) {
                return res.status(401).json({ error: error.message });
            }

            const { data: profile, error: profileError } = await supabaseAdmin
                .from('profiles')
                .select('role, full_name, avatar_url')
                .eq('id', data.user.id)
                .single();

            if (profileError) {
                return res.status(500).json({ error: 'Failed to fetch user profile' });
            }

            res.json({
                user: {
                    ...data.user,
                    role: profile.role,
                    full_name: profile.full_name,
                    avatar_url: profile.avatar_url,
                },
                session: {
                    access_token: data.session.access_token,
                    refresh_token: data.session.refresh_token,
                    expires_at: data.session.expires_at,
                },
            });
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async googleSignIn(req: Request, res: Response) {
        try {
            const { id_token } = req.body;

            if (!id_token) {
                return res.status(400).json({ error: 'Google id_token is required' });
            }

            // 1. Verify Google token
            let payload;
            try {
                const clientId = process.env.GOOGLE_CLIENT_ID;
                if (!clientId) throw new Error('GOOGLE_CLIENT_ID not configured');
                const ticket = await googleClient.verifyIdToken({
                    idToken: id_token,
                    audience: clientId,
                });
                payload = ticket.getPayload();
            } catch (e: any) {
                return res.status(401).json({ error: 'Invalid Google token: ' + e.message });
            }
            if (!payload || !payload.email) {
                return res.status(400).json({ error: 'Could not extract user info from Google token' });
            }

            const { email, name, picture, sub: googleId } = payload;

            // 2. Check if profile already exists
            const { data: existingProfile } = await supabaseAdmin
                .from('profiles')
                .select('id, role, full_name, avatar_url')
                .eq('email', email)
                .maybeSingle();

            let userId: string;
            let userRole: string;
            let userFullName: string;
            let userAvatar: string | null;

            if (existingProfile) {
                userId = existingProfile.id;
                userRole = existingProfile.role;
                userFullName = existingProfile.full_name ?? name ?? '';
                userAvatar = existingProfile.avatar_url ?? picture ?? null;
            } else {
                // 3. Create new Supabase Auth user (auto-confirm since Google already verified email)
                const { data: newAuthUser, error: createError } = await supabaseAdmin.auth.admin.createUser({
                    email: email!,
                    email_confirm: true,
                    user_metadata: { full_name: name, avatar_url: picture, provider: 'google' },
                });

                if (createError || !newAuthUser.user) {
                    return res.status(500).json({ error: createError?.message ?? 'Failed to create user' });
                }

                userId = newAuthUser.user.id;
                userRole = 'user';
                userFullName = name ?? '';
                userAvatar = picture ?? null;

                // 4. Create profile
                await supabaseAdmin.from('profiles').insert({
                    id: userId,
                    email,
                    full_name: userFullName,
                    avatar_url: userAvatar,
                    role: 'user',
                });
            }

            // 5. Sign in the user to get a real session token
            // We set a secure random password during creation and use signInWithPassword
            // For Google users we use the generateLink approach to get a valid session
            const { data: linkData, error: linkError } = await supabaseAdmin.auth.admin.generateLink({
                type: 'magiclink',
                email: email!,
            });

            if (linkError) {
                return res.status(500).json({ error: linkError.message });
            }

            // Extract token from the magic link and exchange it for a session
            const linkUrl = new URL(linkData.properties.action_link);
            const tokenHash = linkUrl.searchParams.get('token') ?? '';

            const { data: sessionData, error: sessionError } = await supabase.auth.verifyOtp({
                type: 'magiclink',
                token_hash: tokenHash,
            });

            if (sessionError || !sessionData.session) {
                return res.status(500).json({ error: sessionError?.message ?? 'Failed to create session' });
            }

            res.json({
                user: {
                    id: userId,
                    email,
                    role: userRole,
                    full_name: userFullName,
                    avatar_url: userAvatar,
                },
                session: {
                    access_token: sessionData.session.access_token,
                    refresh_token: sessionData.session.refresh_token,
                    expires_at: sessionData.session.expires_at,
                },
            });
        } catch (error: any) {
            console.error('Google sign-in error:', error);
            res.status(500).json({ error: error.message });
        }
    }

    static async refreshToken(req: Request, res: Response) {
        try {
            const { refresh_token } = req.body;

            if (!refresh_token) {
                return res.status(400).json({ error: 'refresh_token is required' });
            }

            const { data, error } = await supabase.auth.refreshSession({ refresh_token });

            if (error || !data.session) {
                return res.status(401).json({ error: 'Invalid or expired refresh token' });
            }

            // Get updated profile
            const { data: profile } = await supabaseAdmin
                .from('profiles')
                .select('role, full_name, avatar_url')
                .eq('id', data.user!.id)
                .single();

            res.json({
                user: {
                    ...data.user,
                    role: profile?.role ?? 'user',
                    full_name: profile?.full_name ?? '',
                    avatar_url: profile?.avatar_url ?? null,
                },
                session: {
                    access_token: data.session.access_token,
                    refresh_token: data.session.refresh_token,
                    expires_at: data.session.expires_at,
                },
            });
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async forgotPassword(req: Request, res: Response) {
        try {
            const { email } = req.body;
            if (!email) return res.status(400).json({ error: 'Email is required' });

            const { error } = await supabase.auth.resetPasswordForEmail(email, {
                redirectTo: process.env.PASSWORD_RESET_REDIRECT_URL ?? 'https://book-backned.vercel.app/reset-password',
            });

            if (error) return res.status(400).json({ error: error.message });

            res.json({ message: 'Password reset email sent' });
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async getMe(req: any, res: Response) {
        try {
            const user = req.user;
            if (!user) return res.status(401).json({ error: 'Not authenticated' });

            const { data: profile, error } = await supabaseAdmin
                .from('profiles')
                .select('*')
                .eq('id', user.id)
                .single();

            if (error) throw error;

            res.json({ ...user, ...profile });
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }

    static async logout(req: any, res: Response) {
        try {
            const authHeader = req.headers.authorization;
            if (authHeader?.startsWith('Bearer ')) {
                const token = authHeader.split(' ')[1];
                await supabase.auth.admin?.signOut(token).catch(() => {});
            }
            res.json({ message: 'Logged out successfully' });
        } catch (error: any) {
            res.status(500).json({ error: error.message });
        }
    }
}
