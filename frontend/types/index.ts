export type UserRole = 'student' | 'teacher' | 'admin';
export type UserStatus = 'active' | 'pending' | 'locked';

export interface User {
  id: number;
  email: string;
  fullName: string;
  studentCode?: string | null;
  avatarUrl?: string | null;
  role: UserRole;
  status: UserStatus;
  createdAt: string;
}
