#include <stdio.h>
#include <string.h>

%%{
    machine hello_world;
    write data;

    action hello {
        printf("Hello, ");
    }

    action world {
        printf("world!\n");
    }

    main := 'HELLO'@hello ' ' 'WORLD'@world '\n';
}%%

int main() {
    int cs;
    %% write init;

    char buf[2] = {0, 0};
    while (true) {
        buf[0] = fgetc(stdin);
        if (feof(stdin) != 0) {
            buf[0] = 0;
        }

        char *p = buf, *pe = buf + strlen(buf);
        %% write exec;
        if (cs == hello_world_error) {
            fprintf(stderr, "hello_world: parse error\n");
            return 1;
        }
        if (cs == hello_world_first_final) {
            return 0;
        }
    }
}
