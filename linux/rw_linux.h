

typedef void (*Key_Event_fp_t)(int key, qboolean down);

extern void (*KBD_Update_fp)(void);
extern void (*KBD_Init_fp)(Key_Event_fp_t fp);
extern void (*KBD_Close_fp)(void);

typedef struct in_state {
	// Pointers to functions back in client, set by vid_so
	void (*IN_CenterView_fp)(void);
	Key_Event_fp_t Key_Event_fp;
	vec_t *viewangles;
	int *in_strafe_state;
} in_state_t;

