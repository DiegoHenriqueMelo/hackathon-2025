import * as React from 'react'
import { Calendar, Clock, MapPin, User, Phone, FileText, MoreVertical } from 'lucide-react'
import { Card, CardContent, CardHeader } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { formatDate, formatTime, cn } from '@/lib/utils'

interface Appointment {
  id: string
  protocol: string
  patient: {
    name: string
    avatar?: string
    phone: string
    email: string
  }
  doctor: {
    name: string
    specialty: string
    avatar?: string
  }
  date: Date
  time: string
  duration: number
  status: 'scheduled' | 'confirmed' | 'completed' | 'cancelled' | 'no-show'
  location: string
  notes?: string
  type: 'consultation' | 'followup' | 'procedure' | 'emergency'
}

interface AppointmentCardProps {
  appointment: Appointment
  className?: string
  variant?: 'default' | 'compact'
  onEdit?: () => void
  onCancel?: () => void
  onConfirm?: () => void
  onComplete?: () => void
}

const statusConfig = {
  scheduled: { label: 'Agendado', variant: 'secondary' as const, color: 'bg-blue-100 text-blue-800' },
  confirmed: { label: 'Confirmado', variant: 'success' as const, color: 'bg-green-100 text-green-800' },
  completed: { label: 'Realizado', variant: 'success' as const, color: 'bg-green-100 text-green-800' },
  cancelled: { label: 'Cancelado', variant: 'error' as const, color: 'bg-red-100 text-red-800' },
  'no-show': { label: 'Faltou', variant: 'warning' as const, color: 'bg-yellow-100 text-yellow-800' },
}

const typeConfig = {
  consultation: { label: 'Consulta', icon: User, color: 'text-blue-600' },
  followup: { label: 'Retorno', icon: Calendar, color: 'text-green-600' },
  procedure: { label: 'Procedimento', icon: FileText, color: 'text-purple-600' },
  emergency: { label: 'Urgência', icon: Clock, color: 'text-red-600' },
}

export function AppointmentCard({
  appointment,
  className,
  variant = 'default',
  onEdit,
  onCancel,
  onConfirm,
  onComplete,
}: AppointmentCardProps) {
  const statusInfo = statusConfig[appointment.status]
  const typeInfo = typeConfig[appointment.type]
  const TypeIcon = typeInfo.icon
  
  const getPatientInitials = (name: string) => {
    return name
      .split(' ')
      .slice(0, 2)
      .map(n => n[0])
      .join('')
      .toUpperCase()
  }
  
  const getDoctorInitials = (name: string) => {
    return name
      .split(' ')
      .slice(0, 2)
      .map(n => n[0])
      .join('')
      .toUpperCase()
  }
  
  if (variant === 'compact') {
    return (
      <Card className={cn('hover:shadow-md transition-all duration-200', className)}>
        <CardContent className="p-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <Avatar className="h-8 w-8">
                <AvatarImage src={appointment.patient.avatar} />
                <AvatarFallback className="bg-medical-100 text-medical-700 text-xs">
                  {getPatientInitials(appointment.patient.name)}
                </AvatarFallback>
              </Avatar>
              
              <div className="min-w-0 flex-1">
                <p className="font-medium text-sm truncate">{appointment.patient.name}</p>
                <div className="flex items-center gap-2 text-xs text-muted-foreground">
                  <Clock className="h-3 w-3" />
                  <span>{formatTime(appointment.date)} ({appointment.duration}min)</span>
                </div>
              </div>
            </div>
            
            <div className="flex items-center gap-2">
              <Badge variant={statusInfo.variant} className="text-xs">
                {statusInfo.label}
              </Badge>
              
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Button variant="ghost" size="icon" className="h-6 w-6">
                    <MoreVertical className="h-3 w-3" />
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end">
                  {onEdit && <DropdownMenuItem onClick={onEdit}>Editar</DropdownMenuItem>}
                  {onConfirm && appointment.status === 'scheduled' && (
                    <DropdownMenuItem onClick={onConfirm}>Confirmar</DropdownMenuItem>
                  )}
                  {onComplete && appointment.status === 'confirmed' && (
                    <DropdownMenuItem onClick={onComplete}>Marcar como Realizado</DropdownMenuItem>
                  )}
                  {onCancel && ['scheduled', 'confirmed'].includes(appointment.status) && (
                    <DropdownMenuItem onClick={onCancel} className="text-red-600">
                      Cancelar
                    </DropdownMenuItem>
                  )}
                </DropdownMenuContent>
              </DropdownMenu>
            </div>
          </div>
        </CardContent>
      </Card>
    )
  }
  
  return (
    <Card className={cn(
      'hover:shadow-md transition-all duration-200 border-l-4',
      appointment.status === 'confirmed' && 'border-l-green-500',
      appointment.status === 'scheduled' && 'border-l-blue-500',
      appointment.status === 'cancelled' && 'border-l-red-500',
      appointment.status === 'completed' && 'border-l-green-600',
      appointment.status === 'no-show' && 'border-l-yellow-500',
      className
    )}>
      <CardHeader className="pb-3">
        <div className="flex items-start justify-between">
          <div className="flex items-center gap-3">
            <div className={cn('p-2 rounded-lg bg-gray-50', typeInfo.color)}>
              <TypeIcon className="h-4 w-4" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h3 className="font-semibold">{typeInfo.label}</h3>
                <Badge variant="outline" className="text-xs">
                  {appointment.protocol}
                </Badge>
              </div>
              <p className="text-sm text-muted-foreground">
                {formatDate(appointment.date)} às {appointment.time}
              </p>
            </div>
          </div>
          
          <div className="flex items-center gap-2">
            <Badge 
              className={cn('text-xs', statusInfo.color)}
              variant="outline"
            >
              {statusInfo.label}
            </Badge>
            
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="ghost" size="icon">
                  <MoreVertical className="h-4 w-4" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end">
                {onEdit && <DropdownMenuItem onClick={onEdit}>Editar</DropdownMenuItem>}
                {onConfirm && appointment.status === 'scheduled' && (
                  <DropdownMenuItem onClick={onConfirm}>Confirmar</DropdownMenuItem>
                )}
                {onComplete && appointment.status === 'confirmed' && (
                  <DropdownMenuItem onClick={onComplete}>Marcar como Realizado</DropdownMenuItem>
                )}
                {onCancel && ['scheduled', 'confirmed'].includes(appointment.status) && (
                  <DropdownMenuItem onClick={onCancel} className="text-red-600">
                    Cancelar
                  </DropdownMenuItem>
                )}
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </div>
      </CardHeader>
      
      <CardContent className="pt-0">
        <div className="space-y-4">
          {/* Patient Info */}
          <div className="flex items-center gap-3">
            <Avatar className="h-10 w-10">
              <AvatarImage src={appointment.patient.avatar} />
              <AvatarFallback className="bg-medical-100 text-medical-700">
                {getPatientInitials(appointment.patient.name)}
              </AvatarFallback>
            </Avatar>
            <div className="flex-1 min-w-0">
              <p className="font-medium">{appointment.patient.name}</p>
              <div className="flex items-center gap-4 text-sm text-muted-foreground">
                <div className="flex items-center gap-1">
                  <Phone className="h-3 w-3" />
                  <span>{appointment.patient.phone}</span>
                </div>
              </div>
            </div>
          </div>
          
          {/* Doctor Info */}
          <div className="flex items-center gap-3">
            <Avatar className="h-8 w-8">
              <AvatarImage src={appointment.doctor.avatar} />
              <AvatarFallback className="bg-blue-100 text-blue-700 text-xs">
                {getDoctorInitials(appointment.doctor.name)}
              </AvatarFallback>
            </Avatar>
            <div>
              <p className="text-sm font-medium">{appointment.doctor.name}</p>
              <p className="text-xs text-muted-foreground">{appointment.doctor.specialty}</p>
            </div>
          </div>
          
          {/* Location & Duration */}
          <div className="flex items-center justify-between text-sm text-muted-foreground">
            <div className="flex items-center gap-1">
              <MapPin className="h-3 w-3" />
              <span>{appointment.location}</span>
            </div>
            <div className="flex items-center gap-1">
              <Clock className="h-3 w-3" />
              <span>{appointment.duration} minutos</span>
            </div>
          </div>
          
          {/* Notes */}
          {appointment.notes && (
            <div className="text-sm">
              <p className="font-medium mb-1">Observações:</p>
              <p className="text-muted-foreground">{appointment.notes}</p>
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  )
}