-- Tabla para las publicaciones de la comunidad
CREATE TABLE IF NOT EXISTS public.community_posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  diagram_id UUID REFERENCES public.diagrams(id) ON DELETE CASCADE,
  caption TEXT NOT NULL,
  likes_count INT DEFAULT 0,
  comments_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Habilitar Row Level Security (RLS)
ALTER TABLE public.community_posts ENABLE ROW LEVEL SECURITY;

-- Políticas de acceso
CREATE POLICY "Publicaciones visibles para todos" 
ON public.community_posts FOR SELECT USING (true);

CREATE POLICY "Usuarios pueden publicar" 
ON public.community_posts FOR INSERT WITH CHECK (auth.uid() = user_id);