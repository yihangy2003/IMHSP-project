export interface LoginRequest {
    username: string
    password: string
}

export interface RegisterRequest {
    username: string
    password: string
    email: string
    phone: string
    roles: string
}

export interface LoginResponse {
    code: number
    message: string
    data: string  // token
} 