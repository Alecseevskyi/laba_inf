//вариант №1
#include <iostream>
using namespace std;

int main() {
    char reload;

    do {
        double income, tax = 0.0;

        cout << "Введите ваш доход: ";
        cin >> income;

        if (income < 0) {
            cout << "Ошибка: доход не может быть отрицательным!" << endl;
        } else {
            if (income <= 50000) {
                tax = income * 0.13;
            } else if (income <= 100000) {
                tax = income * 0.20;
            } else {
                tax = income * 0.25;
            }

            cout << "Сумма налога: " << tax << " рублей" << endl;
        }

        cout << "Хотите продолжить расчет? (введите 1 для продолжения и любой символ для выхода): ";
        cin >> reload;

    } while (reload == '1');

    cout << "Программа завершена. Спасибо за использование!" << endl;

    return 0;
}
