//
// d_scana.s
// x86 assembly-language turbulent texture mapping code
//

#include "qasm.h"
#include "d_ifacea.h"

#if id386

	.data

	.text

//----------------------------------------------------------------------
// turbulent texture mapping code
//----------------------------------------------------------------------

	.align 4
.globl C(D_DrawTurbulent8Span)
C(D_DrawTurbulent8Span):
	pushl	%ebp				// preserve caller's stack frame pointer
	pushl	%esi				// preserve register variables
	pushl	%edi
	pushl	%ebx

	movl	C(r_turb_s),%esi
	movl	C(r_turb_t),%ecx
	movl	C(r_turb_pdest),%edi
	movl	C(r_turb_spancount),%ebx

Llp:
	movl	%ecx,%eax
	movl	%esi,%edx
	sarl	$16,%eax
	movl	C(r_turb_turb),%ebp
	sarl	$16,%edx
	andl	$(CYCLE-1),%eax
	andl	$(CYCLE-1),%edx
	movl	(%ebp,%eax,4),%eax
	movl	(%ebp,%edx,4),%edx
	addl	%esi,%eax
	sarl	$16,%eax
	addl	%ecx,%edx
	sarl	$16,%edx
	andl	$(TURB_TEX_SIZE-1),%eax
	andl	$(TURB_TEX_SIZE-1),%edx
	shll	$6,%edx
	movl	C(r_turb_pbase),%ebp
	addl	%eax,%edx
	incl	%edi
	addl	C(r_turb_sstep),%esi
	addl	C(r_turb_tstep),%ecx
	movb	(%ebp,%edx,1),%dl
	decl	%ebx
	movb	%dl,-1(%edi)
	jnz		Llp

	movl	%edi,C(r_turb_pdest)

	popl	%ebx				// restore register variables
	popl	%edi
	popl	%esi
	popl	%ebp				// restore caller's stack frame pointer
	ret

#endif	// id386

