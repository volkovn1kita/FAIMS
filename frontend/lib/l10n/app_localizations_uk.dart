// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get settings => 'Налаштування';

  @override
  String get analytics => 'Аналітика';

  @override
  String get logout => 'Вийти';

  @override
  String get faimsMenu => 'FAIMS МЕНЮ';

  @override
  String welcomeUser(Object userName) {
    return 'Вітаємо, $userName';
  }

  @override
  String get overview => 'Огляд';

  @override
  String get shortcuts => 'Швидкі дії';

  @override
  String get home => 'Головна';

  @override
  String get profile => 'Профіль';

  @override
  String get myFirstAidKit => 'Моя аптечка';

  @override
  String get retry => 'Повторити';

  @override
  String get notAssignedToKit => 'Вас не закріплено за жодною аптечкою.';

  @override
  String get userRoleUser => 'Користувач';

  @override
  String get medications => 'Медикаменти';

  @override
  String get items => 'одиниць';

  @override
  String get add => 'Додати';

  @override
  String get searchMedicationHint => 'Пошук за назвою...';

  @override
  String get expired => 'Протерміновано';

  @override
  String get critical => 'Критично';

  @override
  String get lowStock => 'Закінчується';

  @override
  String get noMedicationsYet => 'Медикаментів ще немає';

  @override
  String get tapToAddMedication =>
      'Натисніть \'Додати\', щоб додати перший медикамент';

  @override
  String get noMedicationsFound => 'Медикаментів не знайдено';

  @override
  String get adjustSearchFilters => 'Спробуйте змінити фільтри пошуку';

  @override
  String get department => 'Підрозділ';

  @override
  String get room => 'Кімната';

  @override
  String get quantity => 'Кількість';

  @override
  String get expires => 'Термін до';

  @override
  String get writeOff => 'Списати';

  @override
  String get use => 'Використати';

  @override
  String get cancel => 'Скасувати';

  @override
  String get reasonRequired => 'Причина (обов\'язково)';

  @override
  String get manageKits => 'Управління аптечками';

  @override
  String get attention => 'Увага';

  @override
  String get manageUsers => 'Управління користувачами';

  @override
  String get departments => 'Підрозділи';

  @override
  String get totalKits => 'Всі аптечки';

  @override
  String get kitsNeedingAttention => 'Потребують уваги';

  @override
  String get users => 'Користувачі';

  @override
  String get minRequired => 'Мін. вимога';

  @override
  String get statusWarning => 'Увага';

  @override
  String get statusGood => 'Добре';

  @override
  String get lowStockWarning => '(Закінчується!)';

  @override
  String useMedicationTitle(Object medicationName) {
    return 'Використати $medicationName';
  }

  @override
  String get available => 'Доступно';

  @override
  String get quantityToUse => 'Кількість для використання';

  @override
  String get enterValidQuantity => 'Будь ласка, введіть дійсну кількість';

  @override
  String get notEnoughAvailable => 'Недостатньо медикаментів';

  @override
  String get medicationUsedSuccess => 'Медикамент успішно використано!';

  @override
  String writeOffMedicationTitle(Object medicationName) {
    return 'Списати $medicationName';
  }

  @override
  String get quantityToWriteOff => 'Кількість для списання';

  @override
  String get reasonHint => 'напр., Пошкоджено, Протерміновано, Втрачено';

  @override
  String get reasonIsRequired => 'Причина є обов\'язковою';

  @override
  String get medicationWrittenOffSuccess => 'Медикамент успішно списано!';

  @override
  String get addNewMedication => 'Додати Новий Медикамент';

  @override
  String get medicationName => 'Назва медикаменту';

  @override
  String get minimumQuantity => 'Мінімальна кількість';

  @override
  String get unit => 'Одиниця виміру';

  @override
  String get expirationDate => 'Термін придатності';

  @override
  String get enterMedicationName => 'Будь ласка, введіть назву медикаменту';

  @override
  String get medicationAddedSuccess => 'Медикамент успішно додано!';

  @override
  String get editDepartment => 'Редагувати підрозділ';

  @override
  String get addDepartment => 'Додати підрозділ';

  @override
  String get departmentName => 'Назва підрозділу';

  @override
  String get enterDepartmentNameHint => 'Введіть назву підрозділу';

  @override
  String get departmentNameValidator => 'Будь ласка, введіть назву підрозділу';

  @override
  String get saveChanges => 'Зберегти зміни';

  @override
  String get departmentUpdatedSuccess => 'Підрозділ успішно оновлено!';

  @override
  String get departmentAddedSuccess => 'Підрозділ успішно додано!';

  @override
  String failedToSaveDepartment(Object error) {
    return 'Не вдалося зберегти підрозділ: $error';
  }

  @override
  String get editKitTitle => 'Редагувати аптечку';

  @override
  String get addKitTitle => 'Додати нову аптечку';

  @override
  String get kitDetails => 'Деталі аптечки';

  @override
  String get kitName => 'Назва аптечки';

  @override
  String get kitNameHint => 'напр., Аптечка №1 або Аптечка операційної';

  @override
  String get kitNameRequired => 'Назва аптечки є обов\'язковою';

  @override
  String get kitNameMinChars => 'Мін. 3 символи';

  @override
  String get kitNameHelper => 'Мін. 3 - Макс. 50 символів';

  @override
  String get uniqueNumber => 'Унікальний номер';

  @override
  String get uniqueNumberHelper => 'Має бути унікальним. Формат: KIT-#######';

  @override
  String get autoGenerated => 'Авто-згенеровано';

  @override
  String get uniqueNumberRegenerated =>
      'Унікальний номер згенеровано повторно!';

  @override
  String get uniqueNumberRequired => 'Унікальний номер є обов\'язковим';

  @override
  String get ownershipAndLocation => 'Власник та локація';

  @override
  String get selectDepartmentHint => 'Оберіть підрозділ';

  @override
  String get departmentRequired => 'Підрозділ є обов\'язковим';

  @override
  String get roomLocation => 'Кімната/Локація';

  @override
  String get roomHintPreselect => 'Оберіть після вибору підрозділу';

  @override
  String get roomHintSelect => 'Оберіть кімнату';

  @override
  String get roomRequired => 'Кімната/локація є обов\'язковою';

  @override
  String get roomHelperPreselect => 'Спочатку оберіть підрозділ';

  @override
  String get roomHelperOptions => 'Опції завантажуються на основі підрозділу';

  @override
  String get responsiblePerson => 'Відповідальна особа';

  @override
  String get responsiblePersonHint => 'Оберіть співробітника';

  @override
  String get responsiblePersonRequired => 'Відповідальна особа є обов\'язковою';

  @override
  String get responsiblePersonHelper => 'Зі списку відповідальних';

  @override
  String get fieldRequired => 'Обов\'язково';

  @override
  String get fillAllFieldsError =>
      'Будь ласка, заповніть усі обов\'язкові поля.';

  @override
  String get kitAddedSuccess => 'Аптечку успішно додано!';

  @override
  String get kitUpdatedSuccess => 'Аптечку успішно оновлено!';

  @override
  String kitSaveError(Object error) {
    return 'Помилка збереження аптечки: $error';
  }

  @override
  String get deleteKitTitle => 'Видалити Аптечку';

  @override
  String deleteKitConfirmation(Object name, Object number) {
    return 'Ви впевнені, що хочете видалити аптечку \"$name\" ($number)?';
  }

  @override
  String get delete => 'Видалити';

  @override
  String get kitDeleteSuccess => 'Аптечку успішно видалено!';

  @override
  String kitDeleteError(Object error) {
    return 'Помилка видалення аптечки: $error';
  }

  @override
  String get save => 'Зберегти';

  @override
  String get update => 'Оновити';

  @override
  String get editMedication => 'Редагувати медикамент';

  @override
  String get addMedication => 'Додати медикамент';

  @override
  String get medicationCreateHint => 'наприклад Аспірин';

  @override
  String get selectUnit => 'Оберіть одиницб виміру';

  @override
  String get selectQuantityHint => 'наприклад 50';

  @override
  String get enterQuantity => 'Введіть кількість';

  @override
  String get quantityMustBeANumber => 'Кількість має бути числом';

  @override
  String get quantityCannotBeNegative => 'Кількість має бути невід\'ємною';

  @override
  String get selectMinQuantityHint => 'наприклад 10';

  @override
  String get pleaseEnterMinimumQuantity => 'Введіть мінімальну кількість';

  @override
  String get minimumQuantityMustBeANonNegativeNumber =>
      'Мінімальна кількість повинна бути невід\'ємним числом';

  @override
  String get selectExpirationDate => 'Оберіть термін придатності';

  @override
  String get expirationDateCannotBeInThePastForNewMedications =>
      'Термін придатності нових ліків не може бути минулим';

  @override
  String get selectDepartment => 'Виберіть відділ';

  @override
  String get roomUpdatedSuccessfully => 'Кімнату оновлено!';

  @override
  String get roomAddedSuccessfully => 'Кімнату додано!';

  @override
  String get editRoom => 'Редагувати кімнату';

  @override
  String get addRoom => 'Додати кімнату';

  @override
  String get roomName => 'Назва кімнати';

  @override
  String get roomNameHint => 'Введіть назву кімнати';

  @override
  String get roomNameMissError => 'Будь-ласка введіть назву кімнати';

  @override
  String get editUser => 'Редагувати користувача';

  @override
  String get addNewUser => 'Додати нового користувача';

  @override
  String get firstName => 'Ім\'я';

  @override
  String get enterFirstName => 'Введіть ім\'я';

  @override
  String get lastName => 'Прізвище';

  @override
  String get enterLastName => 'Введіть прізвище';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Введіть email';

  @override
  String get enterValidEmail => 'Введіть коректний email';

  @override
  String get changePassword => 'Змінити пароль (необов\'язково)';

  @override
  String get password => 'Пароль';

  @override
  String get newPassword => 'Новий пароль';

  @override
  String get enterPassword => 'Введіть пароль';

  @override
  String get passwordLenghtHint =>
      'Пароль повинен складатися щонайменше з 6 символів';

  @override
  String get confirmNewPassword => 'Підтвердіть новий пароль';

  @override
  String get confirmPassword => 'Підтвердіть свій пароль';

  @override
  String get passwordDoNotMatch => 'Паролі не збігаються';

  @override
  String get role => 'Роль';

  @override
  String get selectRole => 'Виберіть роль';

  @override
  String get createUser => 'Створити користувача';

  @override
  String get noDataAvailableYet => 'Дані ще не доступні';

  @override
  String get mostExpiredORwrittenOff => 'Найбільш списані';

  @override
  String get mostUsedMedications => 'Найбільш використовувані ліки';

  @override
  String get globalAnalytics => 'Глобальна аналітика';

  @override
  String departmentRooms(Object departmentName) {
    return '$departmentName кімнати';
  }

  @override
  String get addNewRoom => 'Додати нову кімнату';

  @override
  String get noRoomsFound =>
      'Не знайдено кімнат для цього відділу. Додайте одну зараз!';

  @override
  String get deleteRoom => 'Видалити кімнату';

  @override
  String cannotDeleteKit(Object kitName) {
    return 'Неможливо видалити \"$kitName\", оскільки він все ще містить ліки. Спочатку видаліть усі ліки.';
  }

  @override
  String get confirmDeletion => 'Підтвердити видалення';

  @override
  String confirmDeleteFirstAidKit(Object kitName) {
    return 'Ви впевнені, що хочете видалити цю аптечку: \"$kitName\"? Цю дію неможливо скасувати.';
  }

  @override
  String get firstAidKitDeletedSuccessfully =>
      'First aid kit deleted successfully!';

  @override
  String firstAidKitDeleteAlert(Object medicationName) {
    return 'Ви впевнені, що хочете видалити? \"$medicationName\"? Цю дію неможливо скасувати.';
  }

  @override
  String get medicationDeletedSuccessfully => 'Ліки успішно видалені!';

  @override
  String get kitsContent => 'Вміст аптечки';

  @override
  String get kitDetailsNotFound => 'Деталі аптечки не знайдено';

  @override
  String get medication => 'Ліки';

  @override
  String get noMedicationsFoundInThisKit => 'У цій аптечці немає ліків.';

  @override
  String quantityIsGreaterThan0Erorr(Object medicationName) {
    return 'Неможливо видалити \"$medicationName\" оскільки його кількість перевищує 0. Для видалення спочатку встановіть кількість 0.';
  }

  @override
  String get enterEmailAndPassword => 'Please enter email and password';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInLabel => 'Sign in to manage kits, medications and alerts';

  @override
  String get processing => 'Processing';

  @override
  String get login => 'Login';

  @override
  String get cannotDeleteDepartmentWithExistingRooms =>
      'Неможливо видалити відділ, у якому є кімнати. Спочатку видаліть кімнати.';

  @override
  String get deleteDepartmentAlert =>
      'Ви впевнені, що хочете видалити цей відділ? Цю дію неможливо скасувати.';

  @override
  String get departmentDeletedSuccessfully => 'Відділ успішно видалено!';

  @override
  String get manageDepartments => 'Управління відділами';

  @override
  String get addNewDepartment => 'Додати новий відділ';

  @override
  String get noDepartmentsFound => 'Відділів не знайдено. Додайте один зараз!';

  @override
  String get deleteDepartment => 'Видалити відділ';

  @override
  String cannotDeleteKitBecauseIsNotEmpty(
    Object kitName,
    Object medicationsLength,
  ) {
    return 'Неможливо видалити \"$kitName\" тому що він все ще містить \"$medicationsLength\" ліки. Спочатку видаліть усі ліки.';
  }

  @override
  String get deleteFirstAidKit => 'Видалити аптечку першої допомоги';

  @override
  String deleteKitAlert(Object kitName) {
    return 'Ви впевнені, що хочете видалити комплект? \"$kitName\"? Цю дію неможливо скасувати.';
  }

  @override
  String kitDeleteSuccessfully(Object kitName) {
    return 'Аптечка \"$kitName\" видалена успішно!';
  }

  @override
  String get errorCheckingMedicationsForKit =>
      'Помилка перевірки ліків для набору';

  @override
  String get deletionError => 'Помилка видалення';

  @override
  String get needsAttention => 'Потребує уваги';

  @override
  String get searchKitsByNameOrID =>
      'Пошук комплектів за назвою або ідентифікатором';

  @override
  String get status => 'Статус';

  @override
  String get responsible => 'Відповідальний';

  @override
  String get noKitsFoundMatchingYourCriteria =>
      'Не знайдено комплектів, що відповідають вашим критеріям.';

  @override
  String get uniqueID => 'Унікальне ID';

  @override
  String get deleteUserAlert =>
      'Ви впевнені, що хочете видалити цього користувача? Цю дію неможливо скасувати.';

  @override
  String get searchByNameOrEmail => 'Пошук за іменем або email';

  @override
  String get filterByRole => 'Фільтрувати за роллю';

  @override
  String get any => 'Будь-який';

  @override
  String get addUser => 'Новий користувач';

  @override
  String get sortByLastName => 'Сортувати за прізв.';

  @override
  String get noUsersFoundMatchingYourCriteria =>
      'Не знайдено користувачів, що відповідають вашим критеріям.';

  @override
  String get deleteUser => 'Видалити користувача';

  @override
  String get newPassAndConfirmPassDoNotMatch =>
      'Новий пароль і підтвердження пароля не збігаються.';

  @override
  String get failedToGetAvatar =>
      'Не вдалося отримати URL-адресу аватара після завантаження.';

  @override
  String get photoLibrary => 'Фотобібліотека';

  @override
  String get removeAvatar => 'Видалити аватар';

  @override
  String get myProfile => 'Мій профіль';

  @override
  String get addAvatar => 'Додати аватар';

  @override
  String get changeAvatar => 'Змінити аватар';

  @override
  String get oldPassword => 'Старий пароль';

  @override
  String get firstNameCannotBeEmpty => 'Ім\'я не може бути порожнім';

  @override
  String get lastNameCannotBeEmpty => 'Прізвище не може бути порожнім';

  @override
  String get emailCannotBeEmpty => 'Email не може бути порожнім';

  @override
  String get camera => 'Камера';
}
