; Night Kernel System APM Routines
; Copyright (c) xxxx Night Kernel Project
;
; The Night Kernel is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
; License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later
; version.

; The Night Kernel is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

; You should have received a copy of the GNU General Public License along with the Night Kernel. If not, see
; <http://www.gnu.org/licenses/>.

; See the included file <GPL License.txt> for the complete text of the GPL License by which this program is covered.

%ifndef APMPOWER
    %define APMPOWER
%endif


;    Bitfields for APM flags:
;    
;    Bit(s)  Description     
;    0      16-bit protected mode interface supported
;    1      32-bit protected mode interface supported
;    2      CPU idle call reduces processor speed
;    3      BIOS power management disabled
;    4      BIOS power management disengaged (APM v1.1)
;    5-7    reserved
;    
;    Values for APM error code:
;    01h    power management functionality disabled
;    02h    interface connection already in effect
;    03h    interface not connected
;    04h    real-mode interface not connected
;    05h    16-bit protected-mode interface already connected
;    06h    16-bit protected-mode interface not supported
;    07h    32-bit protected-mode interface already connected
;    08h    32-bit protected-mode interface not supported
;    09h    unrecognized device ID
;    0Ah    invalid parameter value in CX
;    0Bh    (APM v1.1) interface not engaged
;    0Ch    (APM v1.2) function not supported
;    0Dh    (APM v1.2) Resume Timer disabled
;    0Eh-1Fh reserved for other interface and general errors
;    20h-3Fh reserved for CPU errors
;    40h-5Fh reserved for device errors
;    60h    can't enter requested state
;    61h-7Fh reserved for other system errors
;    80h    no power management events pending
;    81h-85h reserved for other power management event errors
;    86h    APM not present
;    87h-9Fh reserved for other power management event errors
;    A0h-FEh reserved
;    FFh    undefined
;    
;    Values for APM device IDs:
;    0000h  system BIOS
;    0001h  all devices for which the system BIOS manages power
;    01xxh  display (01FFh for all attached display devices)
;    02xxh  secondary storage (02FFh for all attached secondary storage devices)
;    03xxh  parallel ports (03FFh for all attached parallel ports)
;    04xxh  serial ports (04FFh for all attached serial ports)
;    ---APM v1.1+ ---
;    05xxh  network adapters (05FFh for all attached network adapters)
;    06xxh  PCMCIA sockets (06FFh for all)
;    0700h-7FFFh reserved
;    80xxh  system battery devices (APM v1.2)
;    8100h-DFFFh reserved
;    Exxxh  OEM-defined power device IDs
;    F000h-FFFFh reserved
;    
;    Values for system state ID:
;    0000h  ready (not supported for device ID 0001h)
;    0001h  stand-by
;    0002h  suspend
;    0003h  off (not supported for device ID 0001h in APM v1.0)
;    ---APM v1.1---
;    0004h  last request processing notification (only for device ID 0001h)
;    0005h  last request rejected (only for device ID 0001h)
;    0006h-001Fh reserved system states
;    0020h-003Fh OEM-defined system states
;    0040h-007Fh OEM-defined device states
;    0080h-FFFFh reserved device states


; These functions mostly assume all errors are fatal and automatically drop into APMError
; if the carry flag is set

APM10_InstallationCheck:
    ; Check to see if APM is installed
    ; AH = error code (06h,09h,86h) if CF set
    
    mov ax, 0x5300
    xor bx, bx          ; device ID of System BIOS (0000h)
    int 0x15
    
    jc APMError
ret

APM10_ConnectRMInterface:
    ; Connect Real Mode Interface
    ; AH = error code (02h,05h,07h,09h) if CF set
    
    mov ax, 0x5301
    xor bx, bx
    int 0x15
    
    jc .alreadyconnected
    jmp .no_error
    
    .alreadyconnected:
    cmp ah, 0x02
    jne APMError
    
    .no_error:
    xor ax, ax
ret

APM10_Connect16BitPMInterface:
    ; Connect to 16-bit Protected Mode Interface
    ; Return:
    ;   CF clear if successful
    ;   AX = real-mode segment base address of protected-mode 16-bit code
    ;        segment
    ;   BX = offset of entry point
    ;   CX = real-mode segment base address of protected-mode 16-bit data
    ;        segment
    ;   ---APM v1.1---
    ;   SI = APM BIOS code segment length
    ;   DI = APM BIOS data segment length
    ;   CF set on error
;   AH = error code (02h,05h,06h,07h,09h)
    
    mov ax, 0x5302
    xor bx, bx
    int 0x15
    
    jc .alreadyconnected
    jmp .no_error
    
    .alreadyconnected:      ; APM is already connected, not an "error"
    cmp ah, 0x02
    jne APMError
    
    .no_error:
    
ret

APM10_Connect32BitPMInterface:
    ; Connect to 32-bit Protected Mode Interface
    ; Return:
    ;   CF clear if successful
    ;   AX = real-mode segment base address of protected-mode 32-bit code
    ;        segment
    ;   EBX = offset of entry point
    ;   CX = real-mode segment base address of protected-mode 16-bit code
    ;        segment
    ;   DX = real-mode segment base address of protected-mode 16-bit data
    ;        segment
    ;    ---APM v1.1---
    ;   SI = APM BIOS code segment length
    ;   DI = APM BIOS data segment length
    ;   CF set on error
    ;   AH = error code (02h,05h,07h,08h,09h)
    
    mov ax, 0x5303
    xor bx, bx
    int 0x15
    
    jc .alreadyconnected
    jmp .no_error
    
    .alreadyconnected:          ; If already connected, not an "error"
    cmp ah, 0x02
    jne APMError
    
    .no_error:
ret

APM10_DisconnectInterface:
    ; Disconnect Interface
    ; AH = error code (03h,09h) if CF set
    mov ax, 0x5304
    xor bx, bx
    int 0x15
    
    jc APMError
    
    .no_error:
    
ret

APM10_CPUIdle:
    ; CPU Idle - Do not call from within a hardware interrupt handler to prevent
    ;            reentrance problems
    ; AH = error code (03h,0Bh) if CF set
    
    mov ax, 0x5305
    int 0x15
    
    jc APMError  ; Assume all errors are fatal
   
 ret

APMError:
ret

APM10_CPUBusy:
    ; CPU Busy
    ; AH = error code (03h,0Bh) if CF set
    
    mov ax, 0x5306
    int 0x15
    
    jc APMError     ; Assume all errors are fatal
    
ret

APM10_SetPowerStateToStandBy:
    ; Set Power State to StandBy
    ; AH = error code (01h,03h,09h,0Ah,0Bh,60h) if CF set
    ; Note: Should not be called from within a hardware interrupt 
    ; handler to avoid reentrance problems
    
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0001
    int 0x15
    
    jc APMError             ; assume all errors are fatal
ret

APM10_SetPowerStateToSuspend:
    ; Set Power State to Suspend
    ; AH = error code (01h,03h,09h,0Ah,0Bh,60h) if CF set
    ; Note: Should not be called from within a hardware interrupt 
    ; handler to avoid reentrance problems
    
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0002
    int 0x15
    
    jc APMError
ret

APM12_SetPowerStateToOff:
    ; Set Power State to Off
    ; AH = error code (01h,03h,09h,0Ah,0Bh,60h) if CF set
    ; Note: Should not be called from within a hardware interrupt 
    ; handler to avoid reentrance problems
    ;
    ; This should not be supported for device ID 0001h in APM v1.0
    
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0002
    int 0x15
    
    jc APMError             ; assume all errors are fatal
ret
    
APM10_SetPowerState:
    ; Generic set power state BX contains the Device ID
    ; CX contains the System State ID
    ; (see above)
    
    mov ax, 0x5307    
    int 0x15
    
    jc APMError                ; assume all errors are fatal
ret

;    Values for APM event code:
;    0001h  system stand-by request
;    0002h  system suspend request
;    0003h  normal resume system notification
;    0004h  critical resume system notification
;    0005h  battery low notification
;    ---APM v1.1---
;    0006h  power status change notification
;    0007h  update time notification
;    0008h  critical system suspend notification
;    0009h  user system standby request notification
;    000Ah  user system suspend request notification
;    000Bh  system standby resume notification
;    ---APM v1.2---
;    000Ch  capabilities change notification (see AX=5310h)
;    ------
;    000Dh-00FFh reserved system events
;    01xxh  reserved device events
;    02xxh  OEM-defined APM events
;    0300h-FFFFh reserved


APM10_DisablePowerManagement:
    ; BX = device ID for all devices power-managed by APM
    ; 0001h (APM v1.1+)
    ; FFFFh (APM v1.0)
    ; CX = new state
    ; 0000h disabled
    ; 0001h enabled
    ;
    ; Return:
    ;  CF clear if successful
    ;  CF set on error
    ;  AH = error code (01h,03h,09h,0Ah,0Bh)

    mov ax, 0x5308
    xor cx, cx
    int 0x15
    
    jc APMError         ; assume all errors are fatal
ret

APM10_EnablePowerManagement:
    ; BX = device ID for all devices power-managed by APM
    ; 0001h (APM v1.1+)
    ; FFFFh (APM v1.0)
    ; CX = new state
    ; 0000h disabled
    ; 0001h enabled
    ;
    ; Return:
    ;  CF clear if successful
    ;  CF set on error
    ;  AH = error code (01h,03h,09h,0Ah,0Bh)

    mov ax, 0x5308
    mov cx, 0x0001
    int 0x15
    
    jc APMError         ; assume all errors are fatal
ret

APM10_RestorePowerOnDefaults:
    ; Restore Power-On Defaults
    ;  BX = device ID for all devices power-managed by APM
    ;  0001h (APM v1.1)
    ;  FFFFh (APM v1.0)
    
    ; Return:
    ;  CF clear if successful
    ;  CF set on error
    ;  AH = error code (03h,09h,0Bh) 
    
    ; Note: Should not be called from within a hardware 
    ; interrupt handler to avoid reentrance problems   
    
    mov ax, 0x5309
    int 0x15
    
    jc APMError             ; assume all errors are fatal

ret   
 
APM10_GetPowerStatus:
    ; GetPowerStatus
    ; BX = device ID
    ; 0001h all devices power-managed by APM
    ; 80xxh specific battery unit number XXh (01h-FFh) (APM v1.2)

    ; Return:
    ;  CF clear if successful
    ;  BH = AC line status
    ;  00h off-line
    ;  01h on-line
    ;  02h on backup power (APM v1.1)
    ;  FFh unknown
    ;  other reserved
    ;  BL = battery status 
    ;  CH = battery flag (APM v1.1+) 
    ;  CL = remaining battery life, percentage
    ;  00h-64h (0-100) percentage of full charge
    ;  FFh unknown
    ;  DX = remaining battery life, time (APM v1.1) 
    ;  ---if specific battery unit specified---
    ;  SI = number of battery units currently installed
    ;  CF set on error
    ;  AH = error code (09h,0Ah)

    ; Values for APM v1.0+ battery status:
    ;   00h    high
    ;   01h    low
    ;   02h    critical
    ;   03h    charging
    ;   FFh    unknown
    ;   other  reserved        
    ; 
    ; Bitfields for APM v1.1+ battery flag:
    ;
    ; Bit(s)  Description     
    ;   0      high
    ;   1      low
    ;   2      critical
    ;   3      charging
    ;   4      selected battery not present (APM v1.2)
    ;   5-6    reserved (0)
    ;   7      no system battery
    ;
    ;
    ; Bitfields for APM v1.1+ remaining battery life:
    ;
    ; Bit(s)  Description     
    ;
    ;   15     time units:
    ;    0=seconds, 1=minutes
    ;   14-0   battery life in minutes or seconds
    ;
    ;   Note: All bits set (FFh) if unknown
    mov ax, 0x530A
    int 0x15
    
    jc APMError             ; assume all errors are fatal
        
ret

APM10_GetPowerManagementEvent:
    ;
    
    ; Return:
    ; CF clear if successful
    ; BX = event code (see #00479)
    ; CX = event information (APM v1.2) if BX=0003h or BX=0004h
    ;
    ; bit 0:
    ; PCMCIA socket was powered down in suspend state.
    ; CF set on error
    ; AH = error code (03h,0Bh,80h)

    mov ax, 0x530B
    int 0x15
    
    jc APMError
    
ret

APM11_GetPowerState:
    ; Get power state
    ; BX contains device ID
    
    mov ax, 0x530C
    int 0x15
    
    jc APMError
    
ret

; Advanced Power Management v1.1+ - EN/DISABLE DEVICE POWER MANAGEMENT
;
; Input:
;   BX = device ID
;   CX = function
;     0000h disable power management
;     0001h enable power management
;
;  Return:
;   CF clear if successful
;   CF set on error
;   AH = error code (01h,03h,09h,0Ah,0Bh)
;
;  Desc: Specify whether automatic power management should be active for a given device

APM11_DisableDevicePowerManagement:
    
    mov ax, 0x530d
    xor cx, cx
    int 0x15
    
    jc APMError
    
ret

APM11_EnableDevicePowerManagement:
    
    mov ax, 0x530d
    mov cx, 0x0001
    int 0x15
    
    jc APMError
    
ret

    

APM11_DriverVersion:
    ;  Set APM Driver version to 1.2
    Return:
    ;CF clear if successful
    ;AH = APM connection major version (BCD)
    ;AL = APM connection minor version (BCD)
    ;CF set on error
    ;AH = error code (03h,09h,0Bh)
    
    mov ax, 0x530e
    xor bx, bx
    mov cx, 0x0102
    int 0x15
    
    jc APMError
    
ret

; Advanced Power Management v1.1+ - ENGAGE/DISENGAGE POWER MANAGEMENT

;    APM11_DisenagePowerManagement
;    APM11_EngagePowerManagement
;    
;
;    BX = device ID
;    CX = function
;        0000h disengage power management
;        0001h engage power management
;
;  Return:
;    CF clear if successful
;    
;    CF set on error
;    AH = error code (01h,09h) (see #00473)
;
;   Notes: Unlike AX=5308h, this call does not affect the functioning of the APM BIOS. 
;   When cooperative power management is disengaged, the APM BIOS performs automatic power 
;   management of the system or device

APM11_DisengagePowerManagement:
    
    mov ax, 0x530f
    xor cx, cx
    int 0x15
    
    jc APMError
 
ret

APM11_EngagePowerManagement:
    
    mov ax, 0x530f
    mov cx, 0x0001
    int 0x15
    
    jc APMError
    
ret

APM12_GetCapabilities:
    ; BX - device ID (0000h) other values reserved
    
    ; Return:
    ;    CF clear if successful
    ;    BL = number of battery units supported (00h if no system batteries)
    ;    CX = capabilities flags
    ;    CF set on error
    ;    AH = error code (01h,09h,86h)   
    ;    
    ; Bitfields for APM v1.2 capabilities flags:
    ;
    ; Bit(s)  Description     (Table 00480)
    ;    15-8   reserved
    ;    7      PCMCIA Ring Indicator will wake up system from suspend mode
    ;    6      PCMCIA Ring Indicator will wake up system from standby mode
    ;    5      Resume on Ring Indicator will wake up system from suspend mode
    ;    4      Resume on Ring Indicator will wake up system from standby mode
    ;    3      resume timer will wake up system from suspend mode
    ;    2      resume timer will wake up system from standby mode
    ;    1      can enter global suspend state
    ;    0      can enter global standby state
    ;
    ;  Notes: This function is supported via the INT 15, 16-bit protected mode, and 32-bit protected mode interfaces; 
    ;  it does not require that a connection be established prior to use. This function will return the capabilities 
    ;  currently in effect, not any new settings which have been made but do not take effect until a system restart    
    ;
    
    mov ax, 0x5310
    xor bx, bx
    int 0x15
    
    jc APMError
 
ret

; Advanced Power Management v1.2 - GET/SET/DISABLE RESUME TIMER
;
;
;    APM12_DisableTimer
;    APM12_GetResumeTimer
;    APM12_SetResumeTimer
;
;
;   The following functions use the information below
;    BX = device ID
;        0000h (APM BIOS)
;        other reserved
;    CL = function
;        00h disable Resume Timer
;        01h get Resume Timer
;        02h set Resume Timer
;    CH = resume time, seconds (BCD)
;    DL = resume time, minutes (BCD)
;    DH = resume time, hours (BCD)
;    SI = resume date (BCD), high byte = month, low byte = day
;    DI = resume date, year (BCD)
;
;  Return:
;    CF clear if successful
;
;    ---if getting timer---
;    CH = resume time, seconds (BCD)
;    DL = resume time, minutes (BCD)
;    DH = resume time, hours (BCD)
;    SI = resume date (BCD), high byte = month, low byte = day   
;    DI = resume date, year (BCD)
;    
;    CF set on error
;    AH = error code (03h,09h,0Ah,0Bh,0Ch,0Dh,86h)
;
APM12_DisableResumeTimer:

    mov ax, 0x5311
    xor bx, bx
    xor cl, cl
    
    int 0x15
    
    jc APMError
ret

APM12_GetResumeTimer:

    mov ax, 0x5311
    xor bx, bx
    mov cl, 0x02
    
    int 0x15
    
    jc APMError
ret
        
APM12_SetResumeTimer:

    mov ax, 0x5311
    xor bx, bx
    mov cl, 0x02
    
    int 0x15
    
    jc APMError
ret        
  
;  Advanced Power Management v1.2 - ENABLE/DISABLE RESUME ON RING
;
;   APM12_EnableResumeOnRing
;   APM12_DisableResumeOnRing
;   APM12_GetResumeOnRingStatus
;   
;  Input:
;    BX = device ID
;        0000h (APM BIOS)
;        other reserved
;    CL = function
;        00h disable Resume on Ring Indicator
;        01h enable Resume on Ring Indicator
;        02h get Resume on Ring Indicator status
;
;  Return:
;    CF clear if successful
;    CX = resume status (0000h disabled, 0001h enabled)
;    CF set on error
;    AH = error code (03h,09h,0Ah,0Bh,0Ch,86h)
;
;  Notes: This function is supported via the INT 15, 
;  16-bit protected mode, and 32-bit protected mode interfaces

APM12_DisableResumeOnRing:
    ;
    mov ax, 0x5312
    xor bx, bx
    mov cl, 0x00
    int 0x15
    
    jc APMError
ret

APM12_EnableResumeOnRing:
;
    mov ax, 0x5312
    xor bx, bx
    mov cl, 0x01
    int 0x15
    
    jc APMError
ret

APM12_GetResumeOnRingStatus:
;
    mov ax, 0x5312
    xor bx, bx
    mov cl, 0x03
    int 0x15
    
    jc APMError
ret

;   Advanced Power Management v1.2 - ENABLE/DISABLE TIMER-BASED REQUESTS
;
;    APM12_DisableTimerBasedRequests
;    APM12_EnableTimerBasedRequests
;    APM12_GetTimerBasedRequestStatus
;
;   Input:
;    AX = 5313h
;    BX = device ID (see #00474)
;        0000h (APM BIOS)
;        other reserved
;    CL = function
;        00h disable timer-based requests
;        01h enable timer-based requests
;        02h get timer-based requests status
;
;   Return:
;    CF clear if successful
;    CX = timer-based requests status (0000h disabled, 0001h enabled)
;    CF set on error
;    AH = error code (03h,09h,0Ah,0Bh,86h) (see #00473)
;
;   Notes: This function is supported via the INT 15, 16-bit protected mode, 
;   and 32-bit protected mode interfaces. Some BIOSes set AH on return even when 
;   successful

APM12_DisableTimerBasedRequests:
    ;
    mov ax, 0x5313
    xor bx, bx
    mov cl, 0x00
    int 15
    
    jc APMError
ret

APM12_EnableTimerBasedRequests:
    ;
    mov ax, 0x5313
    xor bx, bx
    mov cl, 0x01
    int 15
    
    jc APMError
ret

APM12_GetTimerBasedRequestStatus:
    ;
    mov ax, 0x5313
    xor bx, bx
    mov cl, 0x02
    int 15
    
    jc APMError
ret

