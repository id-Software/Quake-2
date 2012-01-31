LEnter16_16:
 mov al,ds:byte ptr[esi]
 mov cl,ds:byte ptr[esi+ebx]
 mov ah,dh
 add edx,ebp
 mov ch,dh
 lea esi,ds:dword ptr[esi+ebx*2]
 mov ax,ds:word ptr[12345678h+eax*2]
LBPatch0:
 add edx,ebp
 mov ds:word ptr[edi],ax
 mov cx,ds:word ptr[12345678h+ecx*2]
LBPatch1:
 mov ds:word ptr[2+edi],cx
 add edi,04h
 mov al,ds:byte ptr[esi]
 mov cl,ds:byte ptr[esi+ebx]
 mov ah,dh
 add edx,ebp
 mov ch,dh
 lea esi,ds:dword ptr[esi+ebx*2]
 mov ax,ds:word ptr[12345678h+eax*2]
LBPatch2:
 add edx,ebp
 mov ds:word ptr[edi],ax
 mov cx,ds:word ptr[12345678h+ecx*2]
LBPatch3:
 mov ds:word ptr[2+edi],cx
 add edi,04h
 mov al,ds:byte ptr[esi]
 mov cl,ds:byte ptr[esi+ebx]
 mov ah,dh
 add edx,ebp
 mov ch,dh
 lea esi,ds:dword ptr[esi+ebx*2]
 mov ax,ds:word ptr[12345678h+eax*2]
LBPatch4:
 add edx,ebp
 mov ds:word ptr[edi],ax
 mov cx,ds:word ptr[12345678h+ecx*2]
LBPatch5:
 mov ds:word ptr[2+edi],cx
 add edi,04h
 mov al,ds:byte ptr[esi]
 mov cl,ds:byte ptr[esi+ebx]
 mov ah,dh
 add edx,ebp
 mov ch,dh
 lea esi,ds:dword ptr[esi+ebx*2]
 mov ax,ds:word ptr[12345678h+eax*2]
LBPatch6:
 add edx,ebp
 mov ds:word ptr[edi],ax
 mov cx,ds:word ptr[12345678h+ecx*2]
LBPatch7:
 mov ds:word ptr[2+edi],cx
 add edi,04h
LEnter8_16:
 mov al,ds:byte ptr[esi]
 mov cl,ds:byte ptr[esi+ebx]
 mov ah,dh
 add edx,ebp
 mov ch,dh
 lea esi,ds:dword ptr[esi+ebx*2]
 mov ax,ds:word ptr[12345678h+eax*2]
LBPatch8:
 add edx,ebp
 mov ds:word ptr[edi],ax
 mov cx,ds:word ptr[12345678h+ecx*2]
LBPatch9:
 mov ds:word ptr[2+edi],cx
 add edi,04h
 mov al,ds:byte ptr[esi]
 mov cl,ds:byte ptr[esi+ebx]
 mov ah,dh
 add edx,ebp
 mov ch,dh
 lea esi,ds:dword ptr[esi+ebx*2]
 mov ax,ds:word ptr[12345678h+eax*2]
LBPatch10:
 add edx,ebp
 mov ds:word ptr[edi],ax
 mov cx,ds:word ptr[12345678h+ecx*2]
LBPatch11:
 mov ds:word ptr[2+edi],cx
 add edi,04h
LEnter4_16:
 mov al,ds:byte ptr[esi]
 mov cl,ds:byte ptr[esi+ebx]
 mov ah,dh
 add edx,ebp
 mov ch,dh
 lea esi,ds:dword ptr[esi+ebx*2]
 mov ax,ds:word ptr[12345678h+eax*2]
LBPatch12:
 add edx,ebp
 mov ds:word ptr[edi],ax
 mov cx,ds:word ptr[12345678h+ecx*2]
LBPatch13:
 mov ds:word ptr[2+edi],cx
 add edi,04h
LEnter2_16:
 mov al,ds:byte ptr[esi]
 mov cl,ds:byte ptr[esi+ebx]
 mov ah,dh
 add edx,ebp
 mov ch,dh
 lea esi,ds:dword ptr[esi+ebx*2]
 mov ax,ds:word ptr[12345678h+eax*2]
LBPatch14:
 add edx,ebp
 mov ds:word ptr[edi],ax
 mov cx,ds:word ptr[12345678h+ecx*2]
LBPatch15:
 mov ds:word ptr[2+edi],cx
 add edi,04h
