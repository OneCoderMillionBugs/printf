#define NULL (void*)0
#define size_t unsigned int

#if defined _WIN32 || _WIN64
    typedef unsigned char* va_list;
    #define va_start(list, start) (list = (va_list)(&start + 1))
    #define va_arg(list, type)    (list += sizeof(type), *(type*)(list - sizeof(type)))
    #define va_end(list)          (list = NULL)
#else
    #include <stdarg.h>
#endif

#define BUFFER_SIZE 1 << 13

struct buffer
{
    size_t pos;
    char data[BUFFER_SIZE];
}
typedef Buffer;

int  printf(const char *format, ...);
void formout(Buffer *bf, const char *format, va_list *args);
void int_to_str(char *str, int num, char base);
void reverse(char *str);
char toHex(char num, char base);
size_t strlength(char *str);

extern int write(int n, const char *str, size_t length);

int main(void)
{
    printf("String %s, character %c, and number %d\n", "word", 'A', -666);
    return 0;
}

int printf(const char *format, ...)
{
    va_list args;
    va_start(args, format);

    Buffer buffer = {0};

    while (*format != '\0')
    {
        if (*format == '%' && *(++format) != '%') 
        {
            formout(&buffer, format, &args);
        }
        else
        {
            *(buffer.data + buffer.pos) = *format;
            buffer.pos++;
        }
        format++;
    }   

    *(buffer.data + buffer.pos) = '\0';
    write(1, buffer.data, buffer.pos);
    va_end(args);

    return buffer.pos;
}

void formout(Buffer *bf, const char *format, va_list *args)
{
    switch (*format)
    {
        case 'd':
        case 'o':
        case 'x':
        case 'X':;
            int num = va_arg(*args, int);
            char sn[16];
            int_to_str(sn, num, *format);

            for (size_t i = 0; i < 16 && *(sn + i) != '\0'; i++)
            {
                *(bf->data + bf->pos) = *(sn + i);
                bf->pos++;
            }
        break;

        case 'c':;
            char c = (char)va_arg(*args, int);
            *(bf->data + bf->pos) = c;
            bf->pos++;
        break;

        case 's':;
            char *str = va_arg(*args, char *);
            while (*str != '\0') 
            {
                *(bf->data + bf->pos) = *str;
                bf->pos++;
                str++;
            }
        break;
    }
}

void int_to_str(char *str, int num, char base)
{   
    size_t i = 0;
    int div;

    if (base == 'x' || base == 'X')
        div = 16;

    else if (base == 'o')
        div = 8;

    else 
        div = 10;

    if (num < 0) 
    {
        *str = '-';
        num *= -1;
        i++;
    }   

    while (num)
    {
        int temp = num % div;
        num /= div;

        if (temp > 9) 
        {
            temp = toHex((char)temp, base);
        }
        else 
        {
            temp += '0';
        }
        *(str + i) = (char)temp;
        i++;
    }
    *(str + i) = '\0';
    reverse(str);
}   

void reverse(char *str)
{
    size_t length = strlength(str);
    for (size_t i = 0; 2 * i < length; i++)
    {
        char temp = *(str + i);
        *(str + i) = *(str + length - i - 1);
        *(str + length - i - 1) = temp;
    }

    if (*(str + length - 1) == '-')
    {
        for (size_t i = length - 1; i > 0; i--) {
            *(str + i) = *(str + i - 1);
        }
        *str = '-';
    }
}

size_t strlength(char *str)
{
    size_t length = 0;
    while (*str != '\0')
    {
        length++;
        str++;
    }
    return length;
}

char toHex(char num, char base)
{
    if (base == 'X')
        return num + 'A' - 10;

    return num + 'a' - 10;
}