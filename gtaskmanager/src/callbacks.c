/*
 *  xfce4-taskmanager - very simple taskmanger
 *
 *  Copyright (c) 2006 Johannes Zellner, <webmaster@nebulon.de>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Library  General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#include "callbacks.h"

void on_button1_button_press_event(GtkButton *button, GdkEventButton *event)
{
	GdkEventButton *mouseevent = (GdkEventButton *)event; 
	if(mainmenu == NULL)
		mainmenu = create_mainmenu ();
	gtk_menu_popup(GTK_MENU(mainmenu), NULL, NULL, NULL, NULL, mouseevent->button, mouseevent->time);
}

void on_button3_toggled_event(GtkButton *button, GdkEventButton *event)
{
	full_view = gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(button));
	change_list_store_view();
}

gboolean on_treeview1_button_press_event(GtkButton *button, GdkEventButton *event)
{	
	if(event->button == 3)
	{
		GdkEventButton *mouseevent = (GdkEventButton *)event; 
		if(taskpopup == NULL)
			taskpopup = create_taskpopup ();
		gtk_menu_popup(GTK_MENU(taskpopup), NULL, NULL, NULL, NULL, mouseevent->button, mouseevent->time);
	}
	return FALSE;
}

void on_info1_activate(GtkMenuItem *menuitem, gpointer user_data)
{
	show_about_dialog();
}

void handle_task_menu(GtkWidget *widget, gchar *signal)
{
	if(signal != NULL)
	{
		gchar *s;

		if (strcmp(signal, "KILL") == 0) s = _("Really kill the task?");
		else s = _("Really terminate the task?");
		
		GtkWidget *dialog_confirm = gtk_message_dialog_new (NULL, GTK_DIALOG_MODAL, GTK_MESSAGE_QUESTION, GTK_BUTTONS_YES_NO, s);
	
		if(strcmp(signal, "STOP") == 0 || strcmp(signal, "CONT") == 0 || gtk_dialog_run(dialog_confirm) == GTK_RESPONSE_YES)
		{
			gchar *task_id = "";
			GtkTreeModel *model;
			GtkTreeIter iter;

			if(gtk_tree_selection_get_selected(selection, &model, &iter))
			{
				gtk_tree_model_get(model, &iter, 1, &task_id, -1);
				send_signal_to_task(task_id, signal);
				refresh_task_list();
			}
		}
		gtk_widget_destroy (dialog_confirm);
	}
}

void on_show_tasks_toggled (GtkMenuItem *menuitem, gint uid)
{
	if(uid == own_uid)
		show_user_tasks = gtk_check_menu_item_get_active(GTK_CHECK_MENU_ITEM(menuitem));
	else if(uid == 0)
		show_root_tasks = gtk_check_menu_item_get_active(GTK_CHECK_MENU_ITEM(menuitem));
	else
		show_other_tasks = gtk_check_menu_item_get_active(GTK_CHECK_MENU_ITEM(menuitem));
	
	change_task_view();
}

void on_show_cached_as_free_toggled (GtkMenuItem *menuitem, gint uid)
{
	show_cached_as_free = !show_cached_as_free;
	change_task_view();
}

void on_quit(void)
{
	save_config();
	free(config_file);
	
	gtk_main_quit();
}
