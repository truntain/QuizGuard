# 🗄️ Hướng dẫn Cài đặt & Khởi tạo Database PostgreSQL cho Thành viên Nhóm

Tài liệu này hướng dẫn từng bước để mọi thành viên trong nhóm cài đặt cơ sở dữ liệu **PostgreSQL** đồng bộ 100% với dự án **QuizGuard** mà không bị xung đột cấu hình.

---

## 1. Quy ước chung của nhóm

| Thông số | Giá trị thống nhất | Ghi chú |
|---|---|---|
| **Hệ quản trị CSDL** | PostgreSQL (v15+ / v18) | Cài kèm công cụ quản lý **pgAdmin 4** |
| **Tên Database** | `quizguard` | **Bắt buộc viết chữ thường**, không dấu, không khoảng trắng |
| **User mặc định** | `postgres` | User mặc định khi cài PostgreSQL |
| **Mật khẩu khuyến nghị** | `123456` | Nếu máy bạn **đã cài sẵn PostgreSQL với mật khẩu khác**, bạn **không cần cài lại** — chỉ cần điền mật khẩu máy bạn vào file `backend/.env` (xem Bước 3) |
| **Port mặc định** | `5432` | Nếu máy từng cài bản cũ có thể là `5433` (xem mục Xử lý lỗi ở cuối) |

> [!IMPORTANT]
> File `backend/.env` chứa mật khẩu kết nối máy cá nhân **đã được `.gitignore` chặn lại**, không bao giờ bị đẩy lên GitHub. Vì vậy mỗi thành viên có mật khẩu PostgreSQL riêng trên máy mình vẫn làm việc chung hoàn toàn bình thường.

---

## 2. Bước 1: Cài đặt PostgreSQL (bỏ qua nếu máy đã có)

1. Tải bộ cài PostgreSQL cho Windows tại: https://www.postgresql.org/download/windows/
2. Khi chạy trình cài đặt:
   - Giữ nguyên tất cả tùy chọn thành phần mặc định (gồm *PostgreSQL Server* và *pgAdmin 4*).
   - Đến bước nhập **Password** cho superuser `postgres`: nhập **`123456`**.
   - Bước **Port**: giữ mặc định **`5432`**.
   - Bước **Locale**: giữ *Default locale* rồi bấm Next cho đến khi hoàn tất.

---

## 3. Bước 2: Tạo Database trống `quizguard` trên pgAdmin 4

Mở ứng dụng **pgAdmin 4** trên máy tính, nhập mật khẩu `123456` (hoặc mật khẩu của máy bạn) để mở nhánh **`Servers` → `PostgreSQL`**.

Thực hiện **1 trong 2 cách** sau:

### Cách A – Tạo bằng giao diện chuột (Nhanh nhất)
1. Click **chuột phải** vào mục **`Databases`** (dưới nhánh `PostgreSQL`) → chọn **`Create`** → **`Database...`**
2. Tại ô **Database**, gõ chính xác: **`quizguard`** (Owner giữ nguyên `postgres`).
3. Bấm nút **`Save`**.

### Cách B – Tạo bằng lệnh SQL
1. Click **chuột phải** vào database mặc định **`postgres`** → chọn **`Query Tool`**.  
   *(Mẹo: Nếu không thấy ô nhập code SQL do bị khung `Data Output` che mất, vào menu trên cùng chọn **`File` → `Reset Layout`**).*
2. Dán lệnh sau và nhấn **Execute (`F5`)**:
   ```sql
   CREATE DATABASE quizguard
     WITH OWNER = postgres
     ENCODING = 'UTF8';
   ```

> [!WARNING]
> **Tuyệt đối KHÔNG tự chạy tay lệnh `CREATE TABLE` trong pgAdmin 4!**  
> Bạn chỉ cần tạo database `quizguard` **trống**. Toàn bộ 14 bảng, khóa ngoại và dữ liệu mẫu sẽ do **Prisma ORM** tự động tạo ở Bước 4.

---

## 4. Bước 3: Cấu hình file môi trường `.env`

Mở Terminal tại thư mục gốc dự án `QuizGuard` sau khi `git clone` (hoặc `git pull`):

### 4.1. Tạo file `.env` cho Backend
```powershell
cd backend
copy .env.example .env
```

Mở file `backend/.env` vừa tạo lên kiểm tra dòng `DATABASE_URL`:
```env
DATABASE_URL="postgresql://postgres:123456@localhost:5432/quizguard?schema=public"
```
- Nếu mật khẩu PostgreSQL máy bạn là `123456` và port `5432`: **Giữ nguyên không cần sửa gì cả.**
- Nếu máy bạn dùng mật khẩu khác (ví dụ `my_pass`) hoặc port `5433`: Sửa tương ứng thành `postgresql://postgres:my_pass@localhost:5433/quizguard?schema=public`.

### 4.2. Tạo file `.env.local` cho Frontend
```powershell
cd ..\frontend
copy .env.example .env.local
```

---

## 5. Bước 4: Chạy lệnh tạo 14 bảng & nạp dữ liệu mẫu

Tại Terminal đang đứng ở thư mục **`backend`**, chạy lần lượt 3 lệnh sau:

```powershell
# 1. Cài đặt toàn bộ thư viện (tự động sinh luôn Prisma Client)
npm install

# 2. Áp dụng toàn bộ lịch sử SQL từ prisma/migrations để tạo đủ 14 bảng vào PostgreSQL
npm run db:migrate

# 3. Nạp sẵn 4 tài khoản mẫu + 1 câu hỏi mẫu để test đăng nhập và phân quyền
npm run db:seed
```

*(Nếu lệnh `npm run db:migrate` hỏi tên migration khi DB đã khớp sẵn thì không cần nhập gì; chỉ khi tạo bảng lần đầu trên máy bạn, Prisma sẽ tự chạy file migration có sẵn trong `backend/prisma/migrations/` và báo `All migrations have been successfully applied`)*.

### Kiểm tra kết quả trực quan:
- **Cách 1 (Khuyên dùng):** Chạy lệnh sau trong thư mục `backend` để mở giao diện quản lý dữ liệu trên trình duyệt tại `http://localhost:5555`:
  ```powershell
  npm run db:studio
  ```
- **Cách 2 (Trên pgAdmin 4):** Chuột phải vào **`quizguard` → `Refresh`**, mở **`Schemas` → `public` → `Tables`**, bạn sẽ thấy đủ 14 bảng (`users`, `refresh_tokens`, `classes`, `class_members`, `ai_jobs`, `questions`, `question_options`, `tags`, `_QuestionToTag`, `exams`, `exam_questions`, `rooms`, `attempts`, `answers`, `cheat_logs`).

---

## 6. Danh sách tài khoản mẫu sau khi chạy `npm run db:seed`

Tất cả tài khoản dưới đây đều dùng chung mật khẩu đăng nhập web là: **`123456`**

| Vai trò (Role) | Email đăng nhập | Họ tên mẫu | MSSV |
|---|---|---|---|
| **Admin** (`admin`) | `admin@quizguard.vn` | Quản trị viên Hệ thống | — |
| **Giảng viên** (`teacher`) | `teacher@hust.edu.vn` | TS. Nguyễn Văn Hùng | — |
| **Sinh viên 1** (`student`) | `sv1@sis.hust.edu.vn` | Trần Thị Mai | `20235001` |
| **Sinh viên 2** (`student`) | `sv2@sis.hust.edu.vn` | Lê Hoàng Nam | `20235002` |

---

## 7. Quy tắc làm việc nhóm khi có cập nhật Database

1. **Khi kéo code mới của nhóm về (`git pull`):**  
   Nếu thấy có thay đổi trong `backend/package.json` hoặc `backend/prisma/`, luôn chạy lại:
   ```powershell
   cd backend
   npm install
   npm run db:migrate
   ```
2. **Ai được sửa `backend/prisma/schema.prisma`?**  
   Khi cần thêm cột/bảng mới, báo trước trong nhóm để tránh 2 người cùng tạo migration một lúc. Người sửa chạy:
   ```powershell
   npm run db:migrate -- --name ten_thay_doi_ngan_gon
   ```
   rồi commit cả `schema.prisma` lẫn thư mục `prisma/migrations/` mới sinh ra lên Git.

---

## 8. Bảng xử lý nhanh các lỗi thường gặp

| Mã lỗi / Hiện tượng | Nguyên nhân | Cách khắc phục |
|---|---|---|
| `P1000: Authentication failed against database server` | Sai mật khẩu user `postgres` trong `backend/.env` | Mở `backend/.env`, sửa lại đúng mật khẩu lúc bạn đăng nhập vào pgAdmin 4 |
| `P1001: Can't reach database server at localhost:5432` | Dịch vụ PostgreSQL chưa bật hoặc chạy ở port khác (ví dụ `5433`) | Mở pgAdmin 4 → chuột phải vào nhánh `PostgreSQL` → `Properties` → tab `Connection` xem số **Port** rồi sửa lại trong `backend/.env` |
| `P1003: Database quizguard does not exist` | Chưa tạo DB `quizguard` hoặc gõ sai chữ hoa (`QuizGuard`) | Vào pgAdmin 4 tạo lại database viết thường đúng tên `quizguard` (Bước 2) |
| `P3005: The database schema is not empty` | Đã lỡ tự tạo bảng bằng tay trong DB `quizguard` trước khi chạy Prisma | Xóa database `quizguard` trong pgAdmin 4 → tạo lại `quizguard` trống → chạy lại `npm run db:migrate` |
