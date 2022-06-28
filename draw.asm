				.data

a				dd			0.5
strBuffer		db			256 dup (0)
strFormat		db			"%d"
strLen			dd			?
strX			db			"X"
strY			db			"Y"				

				.code

DrawGrid		proc		hdc:HDC, draw_rect:RECT, center:POINT, step:POINT, cnt:POINT

				local		thick_pen:HPEN
				local		thin_pen:HPEN
				local		x:DWORD
				local		y:DWORD
				local		count:DWORD
				local		num:DWORD

				invoke		CreatePen, PS_SOLID, 2, 0
				mov			thick_pen, eax

				invoke		CreatePen, PS_SOLID, 0, 0
				mov			thin_pen, eax

				invoke		SelectObject, hdc, thick_pen

				invoke		MoveToEx, hdc, center.x, 0, NULL
				invoke		LineTo, hdc, center.x, draw_rect.bottom
				invoke		MoveToEx, hdc, 0, center.y, NULL
				invoke		LineTo, hdc, draw_rect.right, center.y

				invoke		SelectObject, hdc, thin_pen
				invoke		SetTextAlign, hdc, TA_TOP or TA_CENTER

				xor			eax, eax
				mov			x, eax
				mov			eax, center.y
				mov			ebx, 3
				sub			eax, ebx
				mov			y, eax

				mov			eax, bounds.X_left
				mov			num, eax

				mov			ecx, cnt.x
				inc			ecx

x_strokes:		push		ecx
				invoke		MoveToEx, hdc, x, y, NULL
				mov			eax, y
				mov			ebx, 6
				add			eax, ebx
				mov			y, eax
				invoke		LineTo, hdc, x, y

				invoke		wsprintfA, ADDR strBuffer, ADDR strFormat, num
				dec			eax
				mov			strLen, eax
				invoke		TextOut, hdc, x, y, offset strBuffer, strLen

				mov			eax, x
				mov			ebx, step.x
				add			eax, ebx
				mov			x, eax
				mov			eax, y
				mov			ebx, 6
				sub			eax, ebx
				mov			y, eax
				inc			num
				pop			ecx
				loop		x_strokes

				mov			eax, y
				mov			ebx, 15
				add			eax, ebx
				mov			y, eax
				mov			eax, x
				mov			ebx, 10
				sub			eax, ebx
				mov			x, eax
				invoke		MoveToEx, hdc, x, y, NULL
				invoke		TextOut, hdc, x, y, offset strX, sizeof strX


				xor			eax, eax
				mov			y, eax
				mov			eax, center.x
				mov			ebx, 3
				sub			eax, ebx
				mov			x, eax

				mov			eax, bounds.Y_up
				mov			num, eax

				mov			eax, x
				mov			ebx, 25
				sub			eax, ebx
				mov			x, eax
				invoke		MoveToEx, hdc, x, y, NULL
				invoke		TextOut, hdc, x, y, offset strY, sizeof strY

				xor			eax, eax
				mov			y, eax
				mov			eax, center.x
				mov			ebx, 3
				sub			eax, ebx
				mov			x, eax

				mov			eax, bounds.Y_up
				mov			num, eax

				mov			ecx, cnt.y
				inc			ecx

y_strokes:		push		ecx
				invoke		MoveToEx, hdc, x, y, NULL
				mov			eax, x
				mov			ebx, 6
				add			eax, ebx
				mov			x, eax
				invoke		LineTo, hdc, x, y
				mov			eax, x
				mov			ebx, 8
				add			eax, ebx
				mov			x, eax

				mov			eax, y
				mov			ebx, 8
				sub			eax, ebx
				mov			y, eax

				cmp			num, 0
				je			aux_j

				invoke		wsprintfA, ADDR strBuffer, ADDR strFormat, num
				dec			eax
				mov			strLen, eax
				invoke		TextOut, hdc, x, y, offset strBuffer, strLen
				jmp			aux_j

aux_l:			jmp			y_strokes				

aux_j:			mov			eax, y
				mov			ebx, 8
				add			eax, ebx
				mov			ebx, step.y
				add			eax, ebx
				mov			y, eax
				mov			eax, x
				mov			ebx, 14
				sub			eax, ebx
				mov			x, eax
				dec			num
				pop			ecx
				loop		aux_l


				ret
DrawGrid		endp

DrawGraph		proc		hdc:HDC, center:POINT, step:POINT, tmp:POINT
				local		pen:HPEN
				local		previous_dot:POINT
				local		current_dot:POINT
				local		temp:DWORD

				invoke		CreatePen, PS_SOLID, 1, 0B0000Fh
				mov			pen, eax
				invoke		SelectObject, hdc, pen

				mov			eax, bounds.X_left
				mov			temp, eax

				mov			eax, step.x
				mul			bounds.X_left
				mov			previous_dot.x, eax
				add			eax, center.x
				mov			current_dot.x, eax
				invoke		Func, temp, step.y
				mul			step.y
				mov			previous_dot.y, eax

				mov			ebx, center.y
				sub			ebx, eax
				mov			current_dot.y, ebx
	
				invoke		MoveToEx, hdc, current_dot.x, current_dot.y, NULL
	
				mov			ecx, tmp.x
l:				push		ecx
				mov			ecx, step.x
l1:				push		ecx
				mov			eax, step.x
				sub			eax, ecx
				inc			eax
				invoke		ValueX, temp, step.x, eax
				invoke		Func, eax, step.y
				mov			previous_dot.y, eax
				inc			previous_dot.x
				inc			current_dot.x
				mov			ebx, center.y
				sub			ebx, eax
				mov			current_dot.y, ebx
				invoke		LineTo, hdc, current_dot.x, current_dot.y
				invoke		MoveToEx, hdc, current_dot.x, current_dot.y, NULL
				pop			ecx
				loop		l1
				pop			ecx
				inc			temp
				loop		l    
				ret
DrawGraph		endp

ValueX			proc		x:DWORD, stepX:DWORD, i:DWORD
				local		tmp:DWORD
	
				finit
				fild		i
				fidiv		stepX
				fild		x
				fadd    
				fstp		tmp
				mov			eax, tmp
    			ret
ValueX			endp

Func			proc		real_X:DWORD, step_Y:DWORD
				local		temp:DWORD			

				finit

				fld			real_X			;st0 = x
				fsin						;st0 = sin(x)
				mov			temp, 5
				fild		temp			;st0 = 5, st1 = sin(x)
				fld			real_X			;st0 = x, st1 = 5, st2 = sin(x)
				fmulp		st(1), st(0)	;st0 = 5x, st1 = sin(x)
				mov			temp, 4
				fild		temp			;st0 = 4, st1 = 5x, st2 = sin(x)
				faddp		st(1), st(0)	;st0 = 5x + 4, st1 = sin(x)
				fdivp		st(1), st(0)	;st0 = sin(x)/(5x + 4)
				fsqrt						;st0 = sqrt(sin(x)/(5x + 4))

				fld1						;st0 = +1.0, st1 = sqrt(sin(x)/(5x + 4))
				fxch						;st0 = sqrt(sin(x)/(5x + 4)), st1 = +1.0
				fyl2x						
				fldln2
				fmulp		st(1), st(0)


				fld			a				;st0 = a, st1 = ln..
				fld			real_X			;st0 = x, st1 = a, st2 = ln..
				fdivp		st(1), st(0)	;st0 = a/x, st1 = ln..


				fldl2e						;st0 = log2(e), st1 = a/x, st2 = ln..				
				fmulp		st(1), st(0)	;st0 = log2(e) * (a/x), st1 = ln..
				fld			st(0)			;st0 = log2(e) * (a/x), st1 = log2(e) * (a/x), st2 = ln..
				frndint						;st0 = [log2(e) * (a/x)], st1 = log2(e) * (a/x), st2 = ln..
				fsub		st(1), st(0)	;st0 = [log2(e) * (a/x)], st1 = {log2(e) * (a/x)}, st2 = ln..
				fxch						;st0 = {log2(e) * (a/x)}, st1 = [log2(e) * (a/x)], st2 = ln..
				f2xm1						;st0 = 2^{log2(e) * (a/x)} - 1, st1 = [log2(e) * (a/x)], st2 = ln..
				fld1						;st0 = +1.0, st1 = 2^{log2(e) * (a/x)} - 1, st2 = [log2(e) * (a/x)], st3 = ln..
				faddp		st(1), st(0)	;st0 = 2^{log2(e) * (a/x)}, st1 = [log2(e) * (a/x)], st2 = ln..
				fscale						;st0 = 2^({log2(e) * (a/x)} + [log2(e) * (a/x)]), st1 = ln..
											;st0 = e^(a/x), st1 = ln..
				fstp		st(1)
				fsubp		st(1), st(0)	;st0 = ln.. - e^(a/x)

				fld			real_X			;st0 = x, st1 = ln...
				fld			real_X			;st0 = x, st1 = x, st2 = ln...
				fld			real_X			;st0 = x, st1 = x, st2 = x, st3 = ln...
				fmulp		st(1), st(0)	;st0 = x^2, st1 = x, st2 = ln...
				mov			temp, 1
				fild		temp			;st0 = 1, st1 = x^2, st2 = x, st3 = ln...
				faddp		st(1), st(0)	;st0 = x^2 + 1, st1 = x, st2 = ln...
				fdivp		st(1), st(0)	;st0 = x / (x^2 + 1), s1 = ln...
				fsin						;st0 = sin(x / (x^2 + 1)), s1 = ln...
				fsqrt						;st0 = sqrt(sin(x / (x^2 + 1))), s1 = ln...
				faddp		st(1), st(0)	;st0 = y

				fild		step_Y			;st0 = step_Y, st1 = real y
				fmulp		st(1), st(0)	;st0 = pixel y as float

				frndint						;st0 = pixel y

				fistp		temp
				mov			eax, temp

				ret
Func			endp				






