#include <gtk/gtk.h>


void
on_window1_destroy                     (GtkObject       *object,
                                        gpointer         user_data);

void
on_btn_reboot_clicked                  (GtkButton       *button,
                                        gpointer         user_data);

void
on_btn_shutdown_clicked                (GtkButton       *button,
                                        gpointer         user_data);

void
on_btn_quit_clicked                    (GtkButton       *button,
                                        gpointer         user_data);
