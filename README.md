## Приложение для выполнения тестового задания.

## Описание

Приложение для ведения списка дел (ToDo List) с возможностью добавления, редактирования, удаления задач.

## Технологии

В проекте используются следующие технологии и библиотеки:

- **iOS SDK**: версия 15.0
- **Swift**: версия 5
- **Architecture**: VIPER
- **UIKit** 
- **CoreData**

## Задачи и цели проекта

 - [x] **1. Список задач:**
   - Отображение списка задач на главном экране.
   - Задача должна содержать название, описание, дату создания и статус (выполнена/не выполнена).
   - Возможность добавления новой задачи.
   - Возможность редактирования существующей задачи.
   - Возможность удаления задачи.

- [x] **2. Загрузка списка задач из dummyjson api:**
   - При первом запуске приложение должно загрузить список задач из указанного json api https://dummyjson.com/todos 
  
- [x] **3. Многопоточность:**
   - Обработка создания, загрузки, редактирования и удаления задач должна выполняться в фоновом потоке с использованием GCD или NSOperation.
   - Интерфейс не должен блокироваться при выполнении операций.

 - [x] **4. CoreData:**
   - Данные о задачах должны сохраняться в CoreData.
   - Приложение должно корректно восстанавливать данные при повторном запуске.
