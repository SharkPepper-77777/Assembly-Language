#include <stdio.h>
int main() {
    char letter = 'a'; // 初始字母为 'a'

    // 使用循环输出26个小写字母
    for (int i = 0; i < 26; i++) {
        printf("%c", letter); // 输出当前字母
        letter++; // 递增字母

        // 每输出13个字母后，换行
        if ((i + 1) % 13 == 0) {
            printf("\n");
        }
    }
    return 0;
}
