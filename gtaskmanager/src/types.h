/* $Id: types.h 2350 2007-01-13 10:12:31Z nick $
 *
 * Copyright (c) 2006 Johannes Zellner, <webmaster@nebulon.de>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#ifndef TYPES_H
#define TYPES_H

#include <gtk/gtk.h>

#define REFRESH_INTERVAL 1000

struct task
{
	gint pid;
	gint ppid;
	gint uid;
	gchar uname[64];
	gchar name[64];
	gchar state[16];
	gint size;
	gint rss;
	gboolean checked;
	gint time;
	gint old_time;
	gdouble time_percentage;
};

typedef struct
{
	guint mem_total;
	guint mem_free;
	guint mem_cached;
	guint cpu_count;
	guint cpu_idle;
	guint cpu_user;
	guint cpu_nice;
	guint cpu_system;
	guint cpu_old_jiffies;
	guint cpu_old_used;
	gboolean valid_proc_reading;
} system_status;

GtkWidget *main_window;

GArray *task_array;
gint tasks;
gint own_uid;

gchar *config_file;

gboolean show_user_tasks;
gboolean show_root_tasks;
gboolean show_other_tasks;

gboolean show_cached_as_free; /* Show memory used Cache as free memory */

gboolean full_view;

guint win_width;
guint win_height;

const gchar *custom_signal_0;
const gchar *custom_signal_1;

#endif
