-- Create profiles table
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  email TEXT UNIQUE,
  full_name TEXT,
  avatar_url TEXT,
  role TEXT DEFAULT 'user',
  class TEXT,
  learning_goal TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create books table
CREATE TABLE books (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  author TEXT,
  description TEXT,
  category TEXT,
  format_type TEXT CHECK (format_type IN ('pdf', 'epub')),
  file_url TEXT,
  cover_url TEXT,
  is_visible BOOLEAN DEFAULT TRUE,
  uploaded_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create quizzes table
CREATE TABLE quizzes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  book_id UUID REFERENCES books(id) ON DELETE SET NULL,
  type TEXT DEFAULT 'book',
  title TEXT NOT NULL,
  description TEXT,
  duration_minutes INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create questions table
CREATE TABLE questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE,
  question_text TEXT NOT NULL,
  image_url TEXT,
  options JSONB NOT NULL, -- Array of {label, text}
  correct_option_index INTEGER NOT NULL,
  explanation TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create user_progress table
CREATE TABLE user_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  book_id UUID REFERENCES books(id) ON DELETE CASCADE,
  current_page INTEGER DEFAULT 0,
  progress_percent NUMERIC(5,2) DEFAULT 0,
  is_completed BOOLEAN DEFAULT FALSE,
  total_minutes_read INTEGER DEFAULT 0,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  last_position TEXT,
  last_opened_at TIMESTAMPTZ DEFAULT NOW(),
  last_read_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, book_id)
);

-- Create reading_sessions table
CREATE TABLE reading_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  book_id UUID REFERENCES books(id) ON DELETE CASCADE,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  ended_at TIMESTAMPTZ,
  start_page INTEGER DEFAULT 0,
  end_page INTEGER DEFAULT 0,
  pages_read INTEGER DEFAULT 0,
  minutes_spent INTEGER DEFAULT 0,
  device_type TEXT,
  source TEXT,
  is_completed BOOLEAN DEFAULT FALSE
);

CREATE TABLE bookmarks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  book_id UUID REFERENCES books(id) ON DELETE CASCADE,
  page INTEGER DEFAULT 0,
  position TEXT,
  label TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  book_id UUID REFERENCES books(id) ON DELETE CASCADE,
  page INTEGER DEFAULT 0,
  position TEXT,
  note_text TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE user_achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  code TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  unlocked_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, code)
);

-- Create quiz_results table
CREATE TABLE quiz_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE,
  score INTEGER NOT NULL,
  completed_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE books ENABLE ROW LEVEL SECURITY;
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE reading_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_results ENABLE ROW LEVEL SECURITY;

-- Policies for Profiles
CREATE POLICY "Public profiles are viewable by everyone" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update their own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

-- Policies for Books
CREATE POLICY "Visible books are viewable by everyone" ON books FOR SELECT USING (is_visible = true);
CREATE POLICY "Admins can manage books" ON books USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
);

CREATE POLICY "Users can view their own progress" ON user_progress FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own progress" ON user_progress FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view their own reading sessions" ON reading_sessions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own reading sessions" ON reading_sessions FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view their own bookmarks" ON bookmarks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own bookmarks" ON bookmarks FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view their own notes" ON notes FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own notes" ON notes FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view their own achievements" ON user_achievements FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own achievements" ON user_achievements FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view their own quiz results" ON quiz_results FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create their own quiz results" ON quiz_results FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create vocabulary table
CREATE TABLE vocabulary (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  word TEXT NOT NULL,
  meaning TEXT NOT NULL,
  example_sentence TEXT,
  category TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create daily_tips table
CREATE TABLE daily_tips (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  author TEXT,
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE vocabulary ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_tips ENABLE ROW LEVEL SECURITY;

-- Policies for Vocabulary
CREATE POLICY "Public vocabulary is viewable by everyone" ON vocabulary FOR SELECT USING (true);
CREATE POLICY "Admins can manage vocabulary" ON vocabulary USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
);

-- Policies for Daily Tips
CREATE POLICY "Public daily tips are viewable by everyone" ON daily_tips FOR SELECT USING (true);
CREATE POLICY "Admins can manage daily tips" ON daily_tips USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
);
-- new

-- Create challenges table
CREATE TABLE challenges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  prize_text TEXT,
  image_url TEXT,
  start_time TIMESTAMPTZ,
  end_time TIMESTAMPTZ,
  duration_minutes INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create challenge_questions table
CREATE TABLE challenge_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  challenge_id UUID REFERENCES challenges(id) ON DELETE CASCADE,
  category TEXT,
  question_text TEXT NOT NULL,
  options JSONB NOT NULL,
  correct_option_index INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create challenge_results table
CREATE TABLE challenge_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  challenge_id UUID REFERENCES challenges(id) ON DELETE CASCADE,
  score INTEGER NOT NULL,
  time_taken_ms INTEGER NOT NULL,
  completed_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, challenge_id)
);

-- Enable RLS for Challenges
ALTER TABLE challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_results ENABLE ROW LEVEL SECURITY;

-- Policies for Challenges
CREATE POLICY "Public challenges are viewable by everyone" ON challenges FOR SELECT USING (true);
CREATE POLICY "Admins can manage challenges" ON challenges USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
);

-- Policies for Challenge Questions
CREATE POLICY "Public challenge questions are viewable by everyone" ON challenge_questions FOR SELECT USING (true);
CREATE POLICY "Admins can manage challenge questions" ON challenge_questions USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
);

-- Policies for Challenge Results
CREATE POLICY "Challenge results are viewable by everyone" ON challenge_results FOR SELECT USING (true);
CREATE POLICY "Users can create their own challenge results" ON challenge_results FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Admins can manage challenge results" ON challenge_results USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
);


ALTER TABLE quizzes 
ADD COLUMN is_visible BOOLEAN DEFAULT TRUE;

-- ==========================================
-- Grammar Section Tables
-- ==========================================

-- Create grammar_units table
CREATE TABLE grammar_units (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  unit_order INTEGER NOT NULL,
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create grammar_lessons table
CREATE TABLE grammar_lessons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  unit_id UUID REFERENCES grammar_units(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content_type TEXT CHECK (content_type IN ('text', 'pdf', 'video')),
  content_data TEXT, 
  lesson_order INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create grammar_progress table
CREATE TABLE grammar_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  lesson_id UUID REFERENCES grammar_lessons(id) ON DELETE CASCADE,
  is_completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMPTZ,
  UNIQUE(user_id, lesson_id)
);

-- Enable RLS for Grammar
ALTER TABLE grammar_units ENABLE ROW LEVEL SECURITY;
ALTER TABLE grammar_lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE grammar_progress ENABLE ROW LEVEL SECURITY;

-- Policies for Grammar
CREATE POLICY "Public grammar units are viewable by everyone" ON grammar_units FOR SELECT USING (true);
CREATE POLICY "Admins can manage grammar units" ON grammar_units USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
);

CREATE POLICY "Public grammar lessons are viewable by everyone" ON grammar_lessons FOR SELECT USING (true);
CREATE POLICY "Admins can manage grammar lessons" ON grammar_lessons USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
);

CREATE POLICY "Users can view their own grammar progress" ON grammar_progress FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own grammar progress" ON grammar_progress FOR ALL USING (auth.uid() = user_id);

-- ==========================================
-- CBSE Board Section Tables
-- ==========================================

-- Create cbse_categories table
CREATE TABLE cbse_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  icon_url TEXT,
  order_index INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create cbse_materials table
CREATE TABLE cbse_materials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID REFERENCES cbse_categories(id) ON DELETE CASCADE,
  material_type TEXT CHECK (material_type IN ('model_paper', 'pyq', 'notes', 'syllabus')),
  title TEXT NOT NULL,
  year TEXT,
  description TEXT,
  file_url TEXT NOT NULL,
  thumbnail_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for CBSE
ALTER TABLE cbse_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE cbse_materials ENABLE ROW LEVEL SECURITY;

-- Policies for CBSE
CREATE POLICY "Public CBSE categories are viewable by everyone" ON cbse_categories FOR SELECT USING (true);
CREATE POLICY "Admins can manage CBSE categories" ON cbse_categories USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
);

CREATE POLICY "Public CBSE materials are viewable by everyone" ON cbse_materials FOR SELECT USING (true);
CREATE POLICY "Admins can manage CBSE materials" ON cbse_materials USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
);