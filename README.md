# 🛡️ QuizGuard

> **Hệ thống tạo đề thi trắc nghiệm và giám sát thi trực tuyến**  
> *Đề tài môn học IT4409 – Công nghệ Web và Dịch vụ trực tuyến (SOICT – ĐHBK Hà Nội)*

---

## 📌 Giới thiệu

**QuizGuard** là nền tảng hỗ trợ giảng viên tạo đề thi trắc nghiệm nhanh chóng từ tài liệu bài giảng có sẵn nhờ **AI**, quản lý ngân hàng câu hỏi, đồng thời tổ chức các phòng thi trực tuyến với cơ chế **giám sát hành vi gian lận theo thời gian thực** (phát hiện chuyển tab, thoát toàn màn hình, chặn copy/paste) mà không cần cài đặt phần mềm phụ trợ.

Chi tiết về phân tích yêu cầu, thiết kế kiến trúc và cơ sở dữ liệu xem tại:  
👉 **[Tài liệu phân tích & thiết kế hệ thống (Overview.md)](./Overview.md)**

---

## 🚀 Tính năng chính

- 🤖 **Sinh câu hỏi bằng AI từ tài liệu:** Giảng viên tải slide/giáo trình (PDF, DOCX, PPTX – không giới hạn dung lượng). Trình duyệt tự tách chữ, lọc và nén ảnh sơ đồ quan trọng, sau đó AI đa phương thức sinh câu hỏi nháp để giảng viên duyệt.
- 📚 **Ngân hàng câu hỏi & Đề thi:** Quản lý câu hỏi linh hoạt (đơn / đa đáp án, gắn tag, độ khó), trộn đề thi theo seed riêng cho từng thí sinh.
- 🔑 **Phòng thi mã PIN:** Mở phòng thi nhanh chóng bằng mã PIN 6 số hoặc QR code, đồng hồ đếm ngược đồng bộ từ server.
- 👁️ **Giám sát chống gian lận Realtime:** Bắt buộc toàn màn hình (Fullscreen), tự động phát hiện và ghi nhận hành vi chuyển tab (`visibilitychange`), mất focus (`blur`), chặn phím tắt và thao tác chuột phải/copy/paste.
- 📊 **Dashboard giám sát cho Giảng viên:** Cập nhật trạng thái làm bài và cảnh báo vi phạm của thí sinh theo thời gian thực qua WebSockets (Socket.IO).
- 📈 **Chấm điểm & Thống kê phổ điểm:** Tự động thu bài khi hết giờ, chấm điểm tức thì và vẽ biểu đồ phổ điểm, phân tích độ khó của từng câu hỏi.

---

## 🛠️ Công nghệ sử dụng

| Tầng | Công nghệ chính |
|---|---|
| **Frontend** | [Next.js](https://nextjs.org/) (App Router, TypeScript, React), [Tailwind CSS](https://tailwindcss.com/), [Axios](https://axios-http.com/), [Socket.IO Client](https://socket.io/), [Chart.js](https://www.chartjs.org/) |
| **Backend** | [NestJS](https://nestjs.com/) (Node.js framework, TypeScript), WebSockets Gateway, Task Scheduling (`@nestjs/schedule`) |
| **Bảo mật** | JWT, Passport, Guards RBAC, Helmet, Throttler (Rate Limit), bcrypt |
| **Cơ sở dữ liệu** | **PostgreSQL** + [Prisma ORM](https://www.prisma.io/) |
| **Trí tuệ nhân tạo** | AI đa phương thức (đọc được cả text và hình ảnh), ví dụ [Google Gemini API](https://ai.google.dev/) |
| **Xử lý tài liệu** | Tại trình duyệt: `pdfjs-dist`, `mammoth`, `jszip`, Web Worker · Hàng đợi nền: BullMQ + Redis |

---

## 📂 Cấu trúc dự án

```text
QuizGuard/
├── frontend/            # Ứng dụng Next.js (Giao diện Sinh viên, Giảng viên, Admin)
│   ├── app/             # App Router (pages, layouts, routes)
│   ├── components/      # UI components tái sử dụng
│   ├── hooks/           # Custom React hooks (useProctor, useSocket, ...)
│   └── services/        # Gọi REST API
├── backend/             # RESTful API & WebSocket Gateway xây dựng bằng NestJS
│   ├── src/
│   │   ├── modules/     # Auth, Questions, AI, Exams, Rooms, Proctor, Reports...
│   │   ├── common/      # Guards, Interceptors, Pipes, Filters
│   │   └── jobs/        # Task cron jobs (tự nộp bài, đóng phòng)
├── Overview.md          # Đặc tả chi tiết phân tích & thiết kế kiến trúc hệ thống
└── README.md            # Tài liệu giới thiệu dự án
```

---

## 💻 Hướng dẫn cài đặt & Khởi chạy cục bộ

### 1. Yêu cầu môi trường
- [Node.js](https://nodejs.org/) (phiên bản v18 trở lên, khuyên dùng v20+)
- [PostgreSQL](https://www.postgresql.org/) (cơ sở dữ liệu)
- Trình quản lý gói `npm` (hoặc `pnpm` / `yarn`)

### 2. Cài đặt & chạy Frontend (Next.js)
```bash
# Di chuyển vào thư mục frontend
cd frontend

# Cài đặt thư viện phụ thuộc
npm install

# Khởi chạy dev server
npm run dev
```
Giao diện người dùng sẽ chạy tại: **`http://localhost:3000`**

### 3. Cài đặt & chạy Backend (NestJS)
```bash
# Mở một terminal khác, di chuyển vào thư mục backend
cd backend

# Cài đặt thư viện phụ thuộc
npm install

# Khởi chạy server ở chế độ dev (watch mode)
npm run start:dev
```
Backend API server sẽ chạy tại: **`http://localhost:3001`** (hoặc port được cấu hình trong file `.env`).

---

## 👥 Thành viên nhóm phát triển
- Đề tài môn học: **IT4409 – Công nghệ Web và Dịch vụ trực tuyến**
- Trường Công nghệ Thông tin & Truyền thông – **Đại học Bách khoa Hà Nội (HUST)**
