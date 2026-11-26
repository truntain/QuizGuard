-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('student', 'teacher', 'admin');

-- CreateEnum
CREATE TYPE "UserStatus" AS ENUM ('active', 'pending', 'locked');

-- CreateEnum
CREATE TYPE "AiJobStatus" AS ENUM ('queued', 'processing', 'done', 'partial', 'failed');

-- CreateEnum
CREATE TYPE "QuestionType" AS ENUM ('single', 'multiple');

-- CreateEnum
CREATE TYPE "Difficulty" AS ENUM ('easy', 'medium', 'hard');

-- CreateEnum
CREATE TYPE "QuestionSource" AS ENUM ('manual', 'ai');

-- CreateEnum
CREATE TYPE "QuestionStatus" AS ENUM ('draft', 'approved', 'archived');

-- CreateEnum
CREATE TYPE "RoomStatus" AS ENUM ('draft', 'scheduled', 'open', 'closed', 'published', 'cancelled');

-- CreateEnum
CREATE TYPE "ResultVisibility" AS ENUM ('none', 'score', 'full');

-- CreateEnum
CREATE TYPE "AttemptStatus" AS ENUM ('in_progress', 'locked', 'submitted', 'auto_submitted', 'graded');

-- CreateEnum
CREATE TYPE "CheatType" AS ENUM ('TAB_HIDDEN', 'WINDOW_BLUR', 'EXIT_FULLSCREEN', 'COPY', 'PASTE', 'CONTEXTMENU', 'BLOCKED_SHORTCUT', 'MULTI_SESSION', 'DISCONNECT');

-- CreateEnum
CREATE TYPE "CheatSeverity" AS ENUM ('low', 'medium', 'high');

-- CreateTable
CREATE TABLE "users" (
    "id" SERIAL NOT NULL,
    "email" TEXT NOT NULL,
    "password_hash" TEXT NOT NULL,
    "full_name" TEXT NOT NULL,
    "student_code" TEXT,
    "avatar_url" TEXT,
    "role" "UserRole" NOT NULL DEFAULT 'student',
    "status" "UserStatus" NOT NULL DEFAULT 'active',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "refresh_tokens" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "token_hash" TEXT NOT NULL,
    "expires_at" TIMESTAMP(3) NOT NULL,
    "revoked" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "refresh_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "classes" (
    "id" SERIAL NOT NULL,
    "teacher_id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "course_code" TEXT,
    "semester" TEXT,
    "join_code" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "classes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "class_members" (
    "class_id" INTEGER NOT NULL,
    "student_id" INTEGER NOT NULL,
    "joined_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "class_members_pkey" PRIMARY KEY ("class_id","student_id")
);

-- CreateTable
CREATE TABLE "ai_jobs" (
    "id" SERIAL NOT NULL,
    "teacher_id" INTEGER NOT NULL,
    "file_name" TEXT NOT NULL,
    "word_count" INTEGER NOT NULL DEFAULT 0,
    "config" JSONB NOT NULL,
    "status" "AiJobStatus" NOT NULL DEFAULT 'queued',
    "progress" INTEGER NOT NULL DEFAULT 0,
    "page_count" INTEGER NOT NULL DEFAULT 0,
    "image_count" INTEGER NOT NULL DEFAULT 0,
    "total_chunks" INTEGER NOT NULL DEFAULT 0,
    "done_chunks" INTEGER NOT NULL DEFAULT 0,
    "generated_count" INTEGER NOT NULL DEFAULT 0,
    "error" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ai_jobs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "questions" (
    "id" SERIAL NOT NULL,
    "owner_id" INTEGER NOT NULL,
    "ai_job_id" INTEGER,
    "content" TEXT NOT NULL,
    "type" "QuestionType" NOT NULL DEFAULT 'single',
    "difficulty" "Difficulty" NOT NULL DEFAULT 'medium',
    "explanation" TEXT,
    "source" "QuestionSource" NOT NULL DEFAULT 'manual',
    "status" "QuestionStatus" NOT NULL DEFAULT 'approved',
    "source_page" INTEGER,
    "image_url" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "questions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "question_options" (
    "id" SERIAL NOT NULL,
    "question_id" INTEGER NOT NULL,
    "content" TEXT NOT NULL,
    "is_correct" BOOLEAN NOT NULL DEFAULT false,
    "order_index" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "question_options_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tags" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "tags_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "exams" (
    "id" SERIAL NOT NULL,
    "owner_id" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "total_points" DECIMAL(5,2) NOT NULL DEFAULT 10,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "exams_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "exam_questions" (
    "exam_id" INTEGER NOT NULL,
    "question_id" INTEGER NOT NULL,
    "order_index" INTEGER NOT NULL DEFAULT 0,
    "points" DECIMAL(5,2) NOT NULL DEFAULT 1,

    CONSTRAINT "exam_questions_pkey" PRIMARY KEY ("exam_id","question_id")
);

-- CreateTable
CREATE TABLE "rooms" (
    "id" SERIAL NOT NULL,
    "exam_id" INTEGER NOT NULL,
    "class_id" INTEGER,
    "owner_id" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "pin" VARCHAR(6) NOT NULL,
    "duration_minutes" INTEGER NOT NULL,
    "open_at" TIMESTAMP(3),
    "close_at" TIMESTAMP(3),
    "status" "RoomStatus" NOT NULL DEFAULT 'draft',
    "exam_snapshot" JSONB NOT NULL,
    "proctor_config" JSONB NOT NULL,
    "shuffle_questions" BOOLEAN NOT NULL DEFAULT true,
    "shuffle_options" BOOLEAN NOT NULL DEFAULT true,
    "result_visibility" "ResultVisibility" NOT NULL DEFAULT 'score',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "rooms_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "attempts" (
    "id" SERIAL NOT NULL,
    "room_id" INTEGER NOT NULL,
    "student_id" INTEGER NOT NULL,
    "started_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deadline" TIMESTAMP(3) NOT NULL,
    "submitted_at" TIMESTAMP(3),
    "status" "AttemptStatus" NOT NULL DEFAULT 'in_progress',
    "violation_count" INTEGER NOT NULL DEFAULT 0,
    "score" DECIMAL(5,2),
    "correct_count" INTEGER,
    "shuffle_seed" INTEGER NOT NULL,
    "ip" TEXT,
    "user_agent" TEXT,

    CONSTRAINT "attempts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "answers" (
    "attempt_id" INTEGER NOT NULL,
    "question_id" INTEGER NOT NULL,
    "selected_options" JSONB NOT NULL,
    "is_correct" BOOLEAN,
    "points_earned" DECIMAL(5,2),
    "saved_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "answers_pkey" PRIMARY KEY ("attempt_id","question_id")
);

-- CreateTable
CREATE TABLE "cheat_logs" (
    "id" SERIAL NOT NULL,
    "attempt_id" INTEGER NOT NULL,
    "type" "CheatType" NOT NULL,
    "duration_ms" INTEGER,
    "question_index" INTEGER,
    "severity" "CheatSeverity" NOT NULL DEFAULT 'low',
    "occurred_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "cheat_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "_QuestionToTag" (
    "A" INTEGER NOT NULL,
    "B" INTEGER NOT NULL,

    CONSTRAINT "_QuestionToTag_AB_pkey" PRIMARY KEY ("A","B")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "refresh_tokens_token_hash_key" ON "refresh_tokens"("token_hash");

-- CreateIndex
CREATE INDEX "refresh_tokens_user_id_idx" ON "refresh_tokens"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "classes_join_code_key" ON "classes"("join_code");

-- CreateIndex
CREATE INDEX "ai_jobs_teacher_id_idx" ON "ai_jobs"("teacher_id");

-- CreateIndex
CREATE INDEX "questions_owner_id_status_idx" ON "questions"("owner_id", "status");

-- CreateIndex
CREATE INDEX "question_options_question_id_idx" ON "question_options"("question_id");

-- CreateIndex
CREATE UNIQUE INDEX "tags_name_key" ON "tags"("name");

-- CreateIndex
CREATE INDEX "exams_owner_id_idx" ON "exams"("owner_id");

-- CreateIndex
CREATE INDEX "rooms_pin_status_idx" ON "rooms"("pin", "status");

-- CreateIndex
CREATE INDEX "rooms_owner_id_idx" ON "rooms"("owner_id");

-- CreateIndex
CREATE INDEX "attempts_status_deadline_idx" ON "attempts"("status", "deadline");

-- CreateIndex
CREATE UNIQUE INDEX "attempts_room_id_student_id_key" ON "attempts"("room_id", "student_id");

-- CreateIndex
CREATE INDEX "cheat_logs_attempt_id_occurred_at_idx" ON "cheat_logs"("attempt_id", "occurred_at");

-- CreateIndex
CREATE INDEX "_QuestionToTag_B_index" ON "_QuestionToTag"("B");

-- AddForeignKey
ALTER TABLE "refresh_tokens" ADD CONSTRAINT "refresh_tokens_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "classes" ADD CONSTRAINT "classes_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "class_members" ADD CONSTRAINT "class_members_class_id_fkey" FOREIGN KEY ("class_id") REFERENCES "classes"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "class_members" ADD CONSTRAINT "class_members_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ai_jobs" ADD CONSTRAINT "ai_jobs_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "questions" ADD CONSTRAINT "questions_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "questions" ADD CONSTRAINT "questions_ai_job_id_fkey" FOREIGN KEY ("ai_job_id") REFERENCES "ai_jobs"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "question_options" ADD CONSTRAINT "question_options_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "questions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "exams" ADD CONSTRAINT "exams_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "exam_questions" ADD CONSTRAINT "exam_questions_exam_id_fkey" FOREIGN KEY ("exam_id") REFERENCES "exams"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "exam_questions" ADD CONSTRAINT "exam_questions_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "questions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rooms" ADD CONSTRAINT "rooms_exam_id_fkey" FOREIGN KEY ("exam_id") REFERENCES "exams"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rooms" ADD CONSTRAINT "rooms_class_id_fkey" FOREIGN KEY ("class_id") REFERENCES "classes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rooms" ADD CONSTRAINT "rooms_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attempts" ADD CONSTRAINT "attempts_room_id_fkey" FOREIGN KEY ("room_id") REFERENCES "rooms"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attempts" ADD CONSTRAINT "attempts_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "answers" ADD CONSTRAINT "answers_attempt_id_fkey" FOREIGN KEY ("attempt_id") REFERENCES "attempts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cheat_logs" ADD CONSTRAINT "cheat_logs_attempt_id_fkey" FOREIGN KEY ("attempt_id") REFERENCES "attempts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_QuestionToTag" ADD CONSTRAINT "_QuestionToTag_A_fkey" FOREIGN KEY ("A") REFERENCES "questions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_QuestionToTag" ADD CONSTRAINT "_QuestionToTag_B_fkey" FOREIGN KEY ("B") REFERENCES "tags"("id") ON DELETE CASCADE ON UPDATE CASCADE;
