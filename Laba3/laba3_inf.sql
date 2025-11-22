-- 1. Создание таблиц

-- Таблица авторов
CREATE TABLE authors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    birth_year INTEGER
);

-- Таблица книг
CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author_id INTEGER REFERENCES authors(id),
    publication_year INTEGER,
    genre VARCHAR(50)
);

-- Таблица пользователей
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    registration_date DATE
);

-- Таблица взятых книг
CREATE TABLE borrowed_books (
    user_id INTEGER REFERENCES users(id),
    book_id INTEGER REFERENCES books(id),
    borrow_date DATE NOT NULL,
    return_date DATE,
    PRIMARY KEY (user_id, book_id, borrow_date)
);

-- 2. Добавление данных

-- Заполнение таблицы авторов
INSERT INTO authors (name, birth_year) VALUES
    ('Лев Толстой', 1828),
    ('Фёдор Достоевский', 1821),
    ('Антон Чехов', 1860),
    ('Александр Пушкин', 1799);

-- Заполнение таблицы книг
INSERT INTO books (title, author_id, publication_year, genre) VALUES
    ('Война и мир', 1, 1869, 'Роман-эпопея'),
    ('Анна Каренина', 1, 1877, 'Роман'),
    ('Преступление и наказание', 2, 1866, 'Роман'),
    ('Идиот', 2, 1869, 'Роман'),
    ('Вишнёвый сад', 3, 1904, 'Пьеса'),
    ('Чайка', 3, 1896, 'Пьеса'),
    ('Евгений Онегин', 4, 1833, 'Роман в стихах'),
    ('Капитанская дочка', 4, 1836, 'Повесть');

-- Заполнение таблицы пользователей
INSERT INTO users (name, registration_date) VALUES
    ('Иван Петров', '2023-01-15'),
    ('Мария Сидорова', '2023-02-20'),
    ('Алексей Иванов', '2023-03-10'),
    ('Елена Козлова', '2023-04-01'),
    ('Сергей Васильев', '2023-05-12');

-- Заполнение таблицы взятых книг
INSERT INTO borrowed_books (user_id, book_id, borrow_date, return_date) VALUES
    (1, 1, '2023-04-01', '2023-04-15'),
    (1, 3, '2023-05-01', '2023-05-10'),
    (2, 3, '2023-04-02', NULL), -- книга еще не возвращена
    (2, 5, '2023-04-10', '2023-04-20'),
    (3, 5, '2023-04-03', '2023-04-17'),
    (4, 2, '2023-05-05', NULL), -- книга еще не возвращена
    (4, 7, '2023-05-10', '2023-05-25'),
    (5, 4, '2023-05-15', NULL); -- книга еще не возвращена

-- 3. Основные запросы

-- Список всех книг определенного автора (Льва Толстого)
SELECT '=== Книги Льва Толстого ===' as info;
SELECT 
    b.id,
    b.title, 
    b.publication_year, 
    b.genre,
    a.name as author_name
FROM books b
JOIN authors a ON b.author_id = a.id
WHERE a.name = 'Лев Толстой';

-- Поиск книг по жанру 'Роман'
SELECT '=== Книги жанра "Роман" ===' as info;
SELECT 
    id,
    title, 
    publication_year,
    genre
FROM books 
WHERE genre = 'Роман';

-- Пользователи, зарегистрированные в период с января по февраль 2023 года
SELECT '=== Пользователи за январь-февраль 2023 ===' as info;
SELECT 
    id,
    name, 
    registration_date 
FROM users 
WHERE registration_date BETWEEN '2023-01-01' AND '2023-02-28'
ORDER BY registration_date;

-- Книги, которые были взяты и еще не возвращены
SELECT '=== Не возвращенные книги ===' as info;
SELECT 
    u.name as user_name,
    b.title as book_title,
    a.name as author_name,
    bb.borrow_date,
    bb.return_date
FROM borrowed_books bb
JOIN users u ON bb.user_id = u.id
JOIN books b ON bb.book_id = b.id
JOIN authors a ON b.author_id = a.id
WHERE bb.return_date IS NULL;

-- 4. Дополнительные задания

-- Отчет о количестве книг, взятых каждым пользователем
SELECT '=== Отчет по количеству взятых книг ===' as info;
SELECT 
    u.id,
    u.name,
    COUNT(bb.book_id) AS borrowed_books_count
FROM users u
LEFT JOIN borrowed_books bb ON u.id = bb.user_id
GROUP BY u.id, u.name
ORDER BY borrowed_books_count DESC;

-- Обновление информации о пользователе
SELECT '=== Обновление информации о пользователе ===' as info;
UPDATE users 
SET 
    name = 'Иван Петров (обновленный)',
    registration_date = '2023-01-20'
WHERE id = 1;

-- Проверка обновления
SELECT '=== Проверка обновления ===' as info;
SELECT * FROM users WHERE id = 1;

-- Функция для удаления пользователя и всех связанных записей
CREATE OR REPLACE FUNCTION delete_user_cascade(user_id INTEGER) 
RETURNS TEXT AS $$
DECLARE
    user_exists BOOLEAN;
    deleted_count INTEGER;
BEGIN
    -- Проверяем существование пользователя
    SELECT EXISTS(SELECT 1 FROM users WHERE id = user_id) INTO user_exists;
    
    IF NOT user_exists THEN
        RETURN 'Пользователь с id ' || user_id || ' не найден';
    END IF;
    
    -- Удаляем в транзакции для обеспечения целостности
    BEGIN
        -- Сначала удаляем записи о взятых книгах
        DELETE FROM borrowed_books WHERE user_id = user_id;
        GET DIAGNOSTICS deleted_count = ROW_COUNT;
        
        -- Затем удаляем самого пользователя
        DELETE FROM users WHERE id = user_id;
        
        RETURN 'Пользователь с id ' || user_id || ' удален. Удалено записей о книгах: ' || deleted_count;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'Ошибка при удалении пользователя: ' || SQLERRM;
    END;
END;
$$ LANGUAGE plpgsql;

-- Демонстрация удаления пользователя
SELECT '=== Демонстрация удаления пользователя ===' as info;

-- Сначала создадим тестового пользователя
INSERT INTO users (name, registration_date) VALUES 
    ('Тестовый Пользователь', '2023-06-01');

-- Найдем его ID
SELECT '=== ID тестового пользователя ===' as info;
SELECT id FROM users WHERE name = 'Тестовый Пользователь';

-- Добавим ему книг
INSERT INTO borrowed_books (user_id, book_id, borrow_date, return_date) 
SELECT 
    id, 
    1, 
    '2023-06-10', 
    NULL
FROM users 
WHERE name = 'Тестовый Пользователь';

-- Проверим что добавилось
SELECT '=== Записи тестового пользователя ===' as info;
SELECT * FROM borrowed_books 
WHERE user_id = (SELECT id FROM users WHERE name = 'Тестовый Пользователь');

-- Удаляем тестового пользователя через функцию
SELECT '=== Удаление тестового пользователя ===' as info;
SELECT delete_user_cascade((SELECT id FROM users WHERE name = 'Тестовый Пользователь'));

-- Проверим что удалилось
SELECT '=== Проверка удаления ===' as info;
SELECT * FROM users WHERE name = 'Тестовый Пользователь';

-- 5. Дополнительные отчеты

-- Подробный отчет по активности пользователей
SELECT '=== Подробный отчет по активности пользователей ===' as info;
SELECT 
    u.id,
    u.name as user_name,
    u.registration_date,
    COUNT(bb.book_id) as total_borrowed,
    COUNT(CASE WHEN bb.return_date IS NULL THEN 1 END) as currently_borrowed,
    COUNT(CASE WHEN bb.return_date IS NOT NULL THEN 1 END) as returned_books,
    MIN(bb.borrow_date) as first_borrow,
    MAX(bb.borrow_date) as last_borrow
FROM users u
LEFT JOIN borrowed_books bb ON u.id = bb.user_id
GROUP BY u.id, u.name, u.registration_date
ORDER BY total_borrowed DESC;

-- Книги по авторам с количеством
SELECT '=== Книги по авторам ===' as info;
SELECT 
    a.name as author_name,
    COUNT(b.id) as books_count,
    STRING_AGG(b.title, ', ') as book_titles
FROM authors a
LEFT JOIN books b ON a.id = b.author_id
GROUP BY a.id, a.name
ORDER BY books_count DESC;

-- Статистика по жанрам
SELECT '=== Статистика по жанрам ===' as info;
SELECT 
    genre,
    COUNT(*) as books_count,
    AVG(publication_year) as avg_publication_year
FROM books
GROUP BY genre
ORDER BY books_count DESC;

-- История всех выдач с полной информацией
SELECT '=== Полная история выдач ===' as info;
SELECT 
    u.name as user_name,
    b.title as book_title,
    a.name as author_name,
    bb.borrow_date,
    bb.return_date,
    CASE 
        WHEN bb.return_date IS NULL THEN 
            'Не возвращена (' || (CURRENT_DATE - bb.borrow_date) || ' дней)'
        ELSE 
            'Возвращена ' || bb.return_date || ' (заняла ' || (bb.return_date - bb.borrow_date) || ' дней)'
    END as status
FROM borrowed_books bb
JOIN users u ON bb.user_id = u.id
JOIN books b ON bb.book_id = b.id
JOIN authors a ON b.author_id = a.id
ORDER BY bb.borrow_date DESC;

-- Функция для поиска книг по автору
CREATE OR REPLACE FUNCTION find_books_by_author(author_name VARCHAR) 
RETURNS TABLE(
    book_id INTEGER,
    book_title VARCHAR,
    publication_year INTEGER,
    genre VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.id,
        b.title,
        b.publication_year,
        b.genre
    FROM books b
    JOIN authors a ON b.author_id = a.id
    WHERE a.name ILIKE '%' || author_name || '%'
    ORDER BY b.publication_year;
END;
$$ LANGUAGE plpgsql;

-- Пример использования функции поиска
SELECT '=== Поиск книг по автору "Чехов" ===' as info;
SELECT * FROM find_books_by_author('Чехов');

-- Функция для возврата книги
CREATE OR REPLACE FUNCTION return_book(
    p_user_id INTEGER,
    p_book_id INTEGER,
    p_borrow_date DATE
) RETURNS TEXT AS $$
BEGIN
    UPDATE borrowed_books 
    SET return_date = CURRENT_DATE
    WHERE user_id = p_user_id 
        AND book_id = p_book_id 
        AND borrow_date = p_borrow_date
        AND return_date IS NULL;
    
    IF NOT FOUND THEN
        RETURN 'Запись о взятии книги не найдена или книга уже возвращена';
    END IF;
    
    RETURN 'Книга успешно возвращена';
END;
$$ LANGUAGE plpgsql;

-- Пример возврата книги
SELECT '=== Возврат книги ===' as info;
SELECT return_book(2, 3, '2023-04-02');

-- Проверяем результат возврата
SELECT '=== Проверка возврата книги ===' as info;
SELECT * FROM borrowed_books WHERE user_id = 2 AND book_id = 3;

-- Финальный отчет по текущему состоянию
SELECT '=== ФИНАЛЬНЫЙ ОТЧЕТ ПО БАЗЕ ДАННЫХ ===' as info;

SELECT 'Авторы:' as section;
SELECT * FROM authors;

SELECT 'Книги:' as section;
SELECT b.id, b.title, a.name as author, b.publication_year, b.genre 
FROM books b JOIN authors a ON b.author_id = a.id;

SELECT 'Пользователи:' as section;
SELECT * FROM users;

SELECT 'Текущие выдачи книг:' as section;
SELECT 
    u.name as user_name,
    b.title as book_title, 
    a.name as author_name,
    bb.borrow_date,
    (CURRENT_DATE - bb.borrow_date) as days_borrowed
FROM borrowed_books bb
JOIN users u ON bb.user_id = u.id
JOIN books b ON bb.book_id = b.id
JOIN authors a ON b.author_id = a.id

WHERE bb.return_date IS NULL;
