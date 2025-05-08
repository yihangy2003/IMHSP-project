const TokenKey = 'IMHSP-Token'
const RoleKey = 'IMHSP-Role'

export const getToken = (): string | null => {
    return localStorage.getItem(TokenKey)
}

export const setToken = (token: string) => {
    localStorage.setItem(TokenKey, token)
}

export const removeToken = () => {
    localStorage.removeItem(TokenKey)
}

export const setUserRole = (role: string) => {
    localStorage.setItem(RoleKey, role)
}

export const getUserRole = (): string | null => {
    return localStorage.getItem(RoleKey)
}

export const removeUserRole = () => {
    localStorage.removeItem(RoleKey)
}

export const clearAuth = () => {
    removeToken()
    removeUserRole()
} 