/* $Id: interface.h 2350 2007-01-13 10:12:31Z nick $
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

#ifndef INTERFACE_H
#define INTERFACE_H

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include <gdk/gdkkeysyms.h>
#include <gtk/gtk.h>

#include "functions.h"
#include "callbacks.h"
#include "types.h"
#include "gcs-i18n.h"

GtkTreeStore *list_store;
GtkTreeSelection *selection;
GtkWidget *treeview;
GtkWidget *mainmenu;
GtkTooltips *tooltips;
GtkWidget *taskpopup;
GtkWidget *cpu_usage_progress_bar;
GtkWidget *mem_usage_progress_bar;
GtkWidget *cpu_usage_progress_bar_box;
GtkWidget *mem_usage_progress_bar_box;

#define COLUMN_NAME	0
#define COLUMN_PID	1
#define COLUMN_PPID	2
#define COLUMN_STATE	3
#define COLUMN_MEM	4
#define COLUMN_RSS	5
#define COLUMN_UNAME	6
#define COLUMN_TIME	7

GtkTreeViewColumn *column;

void change_list_store_view(void);
void create_list_store(void);

GtkWidget* create_main_window (void);
GtkWidget* create_taskpopup (void);
GtkWidget* create_mainmenu (void);

void show_about_dialog(void);

void fill_list_item(gint i, GtkTreeIter *iter);
void add_new_list_item(gint i);
gint compare_list_item(GtkTreeModel *model, GtkTreeIter *a, GtkTreeIter *b, gpointer user_data);
gint compare_int_list_item(GtkTreeModel *model, GtkTreeIter *a, GtkTreeIter *b, gpointer user_data);
gint compare_string_list_item(GtkTreeModel *model, GtkTreeIter *a, GtkTreeIter *b, gpointer user_data);
void remove_list_item(gint i);
void refresh_list_item(gint i);

void change_task_view(void);

#endif
