#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <gtk/gtk.h>

#include "callbacks.h"
#include "interface.h"
#include "support.h"
#include "stdlib.h"


void
on_window1_destroy                     (GtkObject       *object,
                                        gpointer         user_data)
{
gtk_main_quit();
}


void
on_btn_reboot_clicked                  (GtkButton       *button,
                                        gpointer         user_data)
{
   int res;
   res = fork();
   
   if (res == 0) {
   execlp("sudo", "sudo", "reboot", NULL);
   fprintf(stderr, "erreur\n");
   exit(EXIT_FAILURE);
   }
   gtk_main_quit();
}


void
on_btn_shutdown_clicked                (GtkButton       *button,
                                        gpointer         user_data)
{
   int res;
   res = fork();
   
   if (res == 0) {
   execlp("sudo", "sudo", "halt", NULL);
   fprintf(stderr, "erreur\n");
   exit(EXIT_FAILURE);
   }
   gtk_main_quit();
}


void
on_btn_quit_clicked                    (GtkButton       *button,
                                        gpointer         user_data)
{
gtk_main_quit();
}

