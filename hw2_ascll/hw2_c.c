#include <stdio.h>
int main() {
    char letter = 'a'; // ��ʼ��ĸΪ 'a'

    // ʹ��ѭ�����26��Сд��ĸ
    for (int i = 0; i < 26; i++) {
        printf("%c", letter); // �����ǰ��ĸ
        letter++; // ������ĸ

        // ÿ���13����ĸ�󣬻���
        if ((i + 1) % 13 == 0) {
            printf("\n");
        }
    }
    return 0;
}
