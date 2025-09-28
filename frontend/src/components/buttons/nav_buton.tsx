import type { ReactNode } from "react"
import { useNavigate } from "react-router-dom"

interface navButtonProps {
    children: ReactNode
    className?: string
    path: string
}

export default function NavButton({ children, path, className }: navButtonProps) {
    const navigate = useNavigate()

    return (
        <button onClick={() => navigate(path)} className={className}>
            {children}
        </button>
    )
}