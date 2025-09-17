//вариант №1
#include <iostream>
using namespace std;

int main() {
    const double price = 10.0;
    double cost = 0.0;

    cout << "Таблица стоимости покупки посуды" << endl;
    cout << "Цена за единицу: " << price << " рублей" << endl;
    cout << "╔═══════════════╦════════════════╗" << endl;
    cout << "║  Количество   ║    Стоимость   ║" << endl;
    cout << "╠═══════════════╬════════════════╣" << endl;

    // Цикл для создания таблицы
    for (int i = 1; i <= 10; i++) {
        cost = i * price;
        cout << "║\t" << i << "\t║\t" << cost  << "\t" << " ║" << endl;
    }

    cout << "╚═══════════════╩════════════════╝" << endl;

    return 0;
}
