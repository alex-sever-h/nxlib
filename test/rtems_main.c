/* Added to function as a wrapper from 
 * nano-X rtems_main call and usual main entry-point
 */

extern int main(int argc, char **argv);

int rtems_main(int argc, char **argv)
{
  return main(argc, argv);
}

