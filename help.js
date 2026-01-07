// This is your Prisma schema file,
// learn more about it in the docs: https://pris.ly/d/prisma-schema

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// ==========================================
// MÓDULO DE USUARIOS Y AUTENTICACIÓN
// ==========================================

// Usuario base - para TODOS (estudiantes, profesores, admins)
model User {
  id                Int       @id @default(autoincrement())
  microsoftId       String?   @unique @map("microsoft_id") @db.VarChar(255)
  nombreCompleto    String    @map("nombre_completo") @db.VarChar(255)
  email             String    @unique @db.VarChar(255)
  profilePicture    String?   @map("profile_picture") @db.Text
  identificacion    String?   @unique @map("identificacion") @db.VarChar(50)
  isProfileComplete Boolean   @default(false) @map("is_profile_complete")
  
  // 🆕 FASE: Campos de tracking de login
  firstLoginAt      DateTime? @map("first_login_at")
  lastLoginAt       DateTime? @map("last_login_at")
  
  createdAt         DateTime  @default(now()) @map("created_at")
  updatedAt         DateTime  @updatedAt @map("updated_at")
  
  // Relaciones existentes
  roles             UserRole[]
  careers           UserCareer[]
  subjects          UserSubject[]
  taughtSubjects    Subject[] @relation("TeacherSubjects")
  
  // Relaciones con evaluaciones
  teacherEvaluations  Evaluation[]        @relation("TeacherEvaluations")
  studentEvaluations  StudentEvaluation[] @relation("StudentEvaluations")
  
  // 🆕 FASE: Relación con logs de sincronización
  syncLogs          SyncLog[]
  
  @@map("users")
}

// Sistema de roles
model Role {
  id          Int        @id @default(autoincrement())
  name        String     @unique @db.VarChar(50)
  displayName String     @map("display_name") @db.VarChar(100)
  description String?    @db.Text
  createdAt   DateTime   @default(now()) @map("created_at")
  
  users       UserRole[]
  
  @@map("roles")
}

// Tabla intermedia User-Role
model UserRole {
  id         Int      @id @default(autoincrement())
  userId     Int      @map("user_id")
  roleId     Int      @map("role_id")
  assignedAt DateTime @default(now()) @map("assigned_at")
  
  user       User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  role       Role     @relation(fields: [roleId], references: [id], onDelete: Cascade)
  
  @@unique([userId, roleId])
  @@map("user_roles")
}

// ==========================================
// MÓDULO DE CARRERAS Y MATERIAS
// ==========================================

model Career {
  id          Int      @id @default(autoincrement())
  nombre      String   @db.VarChar(255)
  codigo      String   @unique @db.VarChar(50)
  icon        String   @default("school") @db.VarChar(50)
  color       String   @default("0xFF135D66") @db.VarChar(20)
  descripcion String?  @db.Text
  activo      Boolean  @default(true)
  createdAt   DateTime @default(now()) @map("created_at")
  updatedAt   DateTime @updatedAt @map("updated_at")
  
  users    UserCareer[]
  subjects Subject[]
  
  @@map("careers")
}

model Subject {
  id            Int      @id @default(autoincrement())
  nombre        String   @db.VarChar(255)
  codigo        String   @db.VarChar(50)
  careerId      Int      @map("career_id")
  teacherId     Int?     @map("teacher_id")
  semestre      Int      @default(1)
  descripcion   String?  @db.Text
  activo        Boolean  @default(true)
  createdAt     DateTime @default(now()) @map("created_at")
  updatedAt     DateTime @updatedAt @map("updated_at")
  
  career   Career        @relation(fields: [careerId], references: [id], onDelete: Cascade)
  teacher  User?         @relation("TeacherSubjects", fields: [teacherId], references: [id], onDelete: SetNull)
  students UserSubject[]
  
  // Relación con evaluaciones
  evaluations Evaluation[]

  // Codigo unico por carrera (para permitir DCB028V en multiples carreras)
  @@unique([codigo, careerId])
  @@index([careerId])
  @@map("subjects")
}

// Tabla intermedia User-Career
model UserCareer {
  id         Int      @id @default(autoincrement())
  userId     Int      @map("user_id")
  careerId   Int      @map("career_id")
  enrolledAt DateTime @default(now()) @map("enrolled_at")
  
  // 🆕 FASE: Campo período
  periodo    String?  @db.VarChar(50)
  
  user    User    @relation(fields: [userId], references: [id], onDelete: Cascade)
  career  Career  @relation(fields: [careerId], references: [id], onDelete: Cascade)
  
  @@unique([userId, careerId])
  @@map("user_careers")
}

// Tabla intermedia User-Subject
model UserSubject {
  id         Int      @id @default(autoincrement())
  userId     Int      @map("user_id")
  subjectId  Int      @map("subject_id")
  enrolledAt DateTime @default(now()) @map("enrolled_at")
  
  // 🆕 FASE: Campo período
  periodo    String?  @db.VarChar(50)
  
  user    User    @relation(fields: [userId], references: [id], onDelete: Cascade)
  subject Subject @relation(fields: [subjectId], references: [id], onDelete: Cascade)
  
  @@unique([userId, subjectId])
  @@map("user_subjects")
}

// ==========================================
// MÓDULO DE EVALUACIONES
// ==========================================

// Plantilla de evaluación (reutilizable)
model EvaluationTemplate {
  id          Int      @id @default(autoincrement())
  nombre      String   @db.VarChar(255)
  descripcion String?  @db.Text
  activo      Boolean  @default(true)
  createdAt   DateTime @default(now()) @map("created_at")
  updatedAt   DateTime @updatedAt @map("updated_at")
  
  // Una plantilla tiene muchas preguntas
  questions   Question[]
  // Una plantilla puede usarse en muchas evaluaciones
  evaluations Evaluation[]
  
  @@map("evaluation_templates")
}

// Preguntas del formulario
model Question {
  id            Int      @id @default(autoincrement())
  templateId    Int      @map("template_id")
  categoria     String   @db.VarChar(100)  // 'Competencia Disciplinaria', etc.
  aspecto       String   @db.VarChar(100)  // 'Formativo', 'Pedagógico', etc.
  nroPregunta   Int      @map("nro_pregunta")
  enunciado     String   @db.Text
  tipoRespuesta String   @default("escala") @map("tipo_respuesta") @db.VarChar(50) // 'escala', 'texto', 'si_no'
  valorMinimo   Int?     @default(1) @map("valor_minimo")  // Para escala: 1-5
  valorMaximo   Int?     @default(5) @map("valor_maximo")
  esObligatoria Boolean  @default(true) @map("es_obligatoria")
  orden         Int      @default(0)  // Para ordenar preguntas
  activo        Boolean  @default(true)
  createdAt     DateTime @default(now()) @map("created_at")
  
  template  EvaluationTemplate @relation(fields: [templateId], references: [id], onDelete: Cascade)
  responses Response[]
  
  @@unique([templateId, nroPregunta])
  @@map("questions")
}

// Evaluación asignada a un docente para una materia específica
model Evaluation {
  id             Int       @id @default(autoincrement())
  templateId     Int       @map("template_id")
  subjectId      Int       @map("subject_id")
  teacherId      Int       @map("teacher_id")
  periodo        String    @db.VarChar(50)  // '2024-1', '2024-2', etc.
  fechaInicio    DateTime  @map("fecha_inicio")
  fechaCierre    DateTime  @map("fecha_cierre")
  esObligatoria  Boolean   @default(true) @map("es_obligatoria")
  activo         Boolean   @default(true)
  createdAt      DateTime  @default(now()) @map("created_at")
  updatedAt      DateTime  @updatedAt @map("updated_at")
  
  template          EvaluationTemplate    @relation(fields: [templateId], references: [id], onDelete: Restrict)
  subject           Subject               @relation(fields: [subjectId], references: [id], onDelete: Cascade)
  teacher           User                  @relation("TeacherEvaluations", fields: [teacherId], references: [id], onDelete: Cascade)
  
  // Respuestas de estudiantes
  studentResponses  StudentEvaluation[]
  
  @@unique([subjectId, teacherId, periodo])
  @@index([teacherId, periodo])
  @@index([fechaInicio, fechaCierre])
  @@map("evaluations")
}

// Registro de evaluación completada por estudiante
model StudentEvaluation {
  id             Int       @id @default(autoincrement())
  evaluationId   Int       @map("evaluation_id")
  studentId      Int       @map("student_id")
  completada     Boolean   @default(false)
  comentario     String?   @db.Text  // Comentario anónimo del estudiante
  fechaInicio    DateTime? @map("fecha_inicio")  // Cuando empezó a responder
  fechaCompleta  DateTime? @map("fecha_completa") // Cuando terminó
  createdAt      DateTime  @default(now()) @map("created_at")
  updatedAt      DateTime  @updatedAt @map("updated_at")
  
  evaluation Evaluation @relation(fields: [evaluationId], references: [id], onDelete: Cascade)
  student    User       @relation("StudentEvaluations", fields: [studentId], references: [id], onDelete: Cascade)
  
  // Respuestas individuales a preguntas
  responses  Response[]
  
  @@unique([evaluationId, studentId])
  @@index([studentId, completada])
  @@map("student_evaluations")
}

// Respuestas individuales a cada pregunta
model Response {
  id                  Int      @id @default(autoincrement())
  studentEvaluationId Int      @map("student_evaluation_id")
  questionId          Int      @map("question_id")
  valorNumerico       Int?     @map("valor_numerico")  // Para preguntas de escala
  valorTexto          String?  @map("valor_texto") @db.Text  // Para preguntas abiertas
  createdAt           DateTime @default(now()) @map("created_at")
  
  studentEvaluation StudentEvaluation @relation(fields: [studentEvaluationId], references: [id], onDelete: Cascade)
  question          Question          @relation(fields: [questionId], references: [id], onDelete: Cascade)
  
  @@unique([studentEvaluationId, questionId])
  @@map("responses")
}

// ==========================================
// 🆕 MÓDULO DE ADMINISTRACIÓN
// ==========================================

// Tabla de logs de sincronización
model SyncLog {
  id          Int      @id @default(autoincrement())
  adminId     Int      @map("admin_id")
  tipo        String   @db.VarChar(50) // 'students', 'teachers', 'evaluations'
  periodo     String   @db.VarChar(50) // '2025-1', '2025-2', etc.
  resultado   Json     // { estudiantesInscritos: 150, errores: [], detalles: {...} }
  createdAt   DateTime @default(now()) @map("created_at")
  
  admin User @relation(fields: [adminId], references: [id], onDelete: Cascade)
  
  @@index([tipo, periodo])
  @@index([adminId])
  @@map("sync_logs")
}
