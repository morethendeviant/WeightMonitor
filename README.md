# WeightMonitor
Тестовое задание

## **Функциональные требования**

### Основные функции

1. **Добавление записей:** Пользователь должен иметь возможность вводить свой вес, а также указывать дату взвешивания. Эти данные должны сохраняться между сессиями.
2. **Отображение списка всех записей:** Пользователь должен иметь возможность просматривать список всех своих записей о весе, включая дату взвешивания. Данные сортируются по дате в порядке убывания. При добавлении измерений список должен обновляться.

### Дополнительные задачи

1. **Тосты:** показывать «тосты» с сообщениями о добавлении/изменении данных после закрытия экрана редактирования.
2. **Темная тема:** приложение должно поддерживать [Dark Mode](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwi5zaX79bD-AhWPbKQEHTlHCWMQFnoECCwQAQ&url=https%3A%2F%2Fdeveloper.apple.com%2Fdesign%2Fhuman-interface-guidelines%2Ffoundations%2Fdark-mode%2F&usg=AOvVaw1cx66Xi_MuwYODxyn6jGxK).
3. **Редактирование:** пользователь должен иметь возможность отредактировать или удалить любую запись из списка (по свайпу ячейки в истории). При обновлении/удалении измерений список должен обновляться.
4. **Системы измерений:** приложение должно поддерживать различные единицы измерения веса (килограммы, фунты). Это означает, что приложение должно иметь возможность выбора различных единиц измерения веса, чтобы пользователи могли выбрать наиболее удобную для них. При переключении системы все измерения должны пересчитываться.

## **Технические требования**

- Язык программирования: Swift
- Поддержка iOS версии 14 и выше
- Код должен быть написан в едином стиле и соответствовать принципам SOLID
- Приложение должно работать на всех устройствах и иметь адаптивный дизайн
- Для UI должен использоваться UIKit и Auto Layout
- Для хранения данных использовать любую подходящую технологию