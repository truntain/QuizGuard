import { PrismaClient, UserRole, UserStatus, Difficulty, QuestionType } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  const passwordHash = await bcrypt.hash('123456', 10);

  const admin = await prisma.user.upsert({
    where: { email: 'admin@quizguard.vn' },
    update: {},
    create: {
      email: 'admin@quizguard.vn',
      passwordHash,
      fullName: 'Quản trị viên Hệ thống',
      role: UserRole.admin,
      status: UserStatus.active,
    },
  });

  const teacher = await prisma.user.upsert({
    where: { email: 'teacher@hust.edu.vn' },
    update: {},
    create: {
      email: 'teacher@hust.edu.vn',
      passwordHash,
      fullName: 'TS. Nguyễn Văn Hùng',
      role: UserRole.teacher,
      status: UserStatus.active,
    },
  });

  const student1 = await prisma.user.upsert({
    where: { email: 'sv1@sis.hust.edu.vn' },
    update: {},
    create: {
      email: 'sv1@sis.hust.edu.vn',
      passwordHash,
      fullName: 'Trần Thị Mai',
      studentCode: '20235001',
      role: UserRole.student,
      status: UserStatus.active,
    },
  });

  const student2 = await prisma.user.upsert({
    where: { email: 'sv2@sis.hust.edu.vn' },
    update: {},
    create: {
      email: 'sv2@sis.hust.edu.vn',
      passwordHash,
      fullName: 'Lê Hoàng Nam',
      studentCode: '20235002',
      role: UserRole.student,
      status: UserStatus.active,
    },
  });

  const existingQuestions = await prisma.question.count({
    where: { ownerId: teacher.id },
  });

  if (existingQuestions === 0) {
    await prisma.question.create({
      data: {
        ownerId: teacher.id,
        content: 'Phương thức nào của đối tượng Response trong Fetch API dùng để đọc dữ liệu trả về dưới dạng JSON?',
        type: QuestionType.single,
        difficulty: Difficulty.easy,
        explanation: 'response.json() trả về một Promise phân giải thành đối tượng JavaScript từ chuỗi JSON.',
        tags: {
          connectOrCreate: [{ where: { name: 'Web API' }, create: { name: 'Web API' } }],
        },
        options: {
          create: [
            { content: 'response.json()', isCorrect: true, orderIndex: 0 },
            { content: 'response.parseJSON()', isCorrect: false, orderIndex: 1 },
            { content: 'JSON.parse(response)', isCorrect: false, orderIndex: 2 },
            { content: 'response.toObject()', isCorrect: false, orderIndex: 3 },
          ],
        },
      },
    });
  }

  console.log('Seeded users (mật khẩu mặc định: 123456):', {
    admin: admin.email,
    teacher: teacher.email,
    students: [student1.email, student2.email],
  });
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
