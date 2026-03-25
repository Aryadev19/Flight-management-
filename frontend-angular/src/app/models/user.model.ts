export interface User {
  id?: number;
  email: string;
  name: string;
  role: string;
  phoneNumber?: string;
}

export interface AuthResponse {
  token: string;
  email: string;
  name: string;
  role: string;
  message?: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  email: string;
  password: string;
  name: string;
  role: string;
  phoneNumber?: string;
}