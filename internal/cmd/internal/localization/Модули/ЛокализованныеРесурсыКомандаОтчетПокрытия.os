
#Область СлужебныйПрограммныйИнтерфейс

Функция ЛокализованныеСтроки() Экспорт

	ЛокализованныеСтроки = Новый Структура;
	ЛокализованныеСтроки.Вставить("КаталогСОтчетами",     ОписаниеОпцииКаталогСОтчетами());
	ЛокализованныеСтроки.Вставить("ОтчетGenericCoverage", ОписаниеОпцииОтчетGenericCoverage());

	Возврат ЛокализованныеСтроки;

КонецФункции

#КонецОбласти

#Область ЛокализованныеСтроки

Функция ОписаниеОпцииКаталогСОтчетами()
	Возврат НСтр("ru = 'Каталог с файлами покрытия в форматах XML или JSON'");
КонецФункции

Функция ОписаниеОпцииОтчетGenericCoverage()
	Возврат НСтр("ru = 'Файл отчета в формате genericCoverage'");
КонецФункции

#КонецОбласти
