
#Использовать configor
#Использовать "../../converter"

Перем Лог;

#Область КомандаПриложения

Процедура ОписаниеКоманды(Команда) Экспорт
	
	Команда.Опция("i input", "", "Файл с результатами отладки в формате csv")
		.ТСтрока()
		.Обязательный();

	Команда.Опция("o output", "", "Файл покрытия с указанием путей к исходным файлам")
		.ТСтрока()
		.Обязательный();
	
	Команда.Опция("w workspace", "", "Каталог проекта")
		.ТСтрока();

	Команда.Опция("s sources", "", "Каталог исходных текстов конфигурации")
		.ТСтрока();

	Команда.Опция("f format", "XML", "Формат исходных текстов конфигурации (XML или EDT)")
		.ТСтрока();

	Команда.Опция("c config", "", "Конфигурационный файл с расположением исходных текстов")
		.ТСтрока();

	Команда.Опция("j json", Ложь, "Сохранять результаты конвертации во внутреннем JSON-формате")
		.ТБулево();	

КонецПроцедуры

Процедура ВыполнитьКоманду(Знач Команда) Экспорт

	Лог = ПараметрыПриложения.Лог();
	Если Команда.ЗначениеОпции("debug") Тогда
		ПараметрыПриложения.ВключитьРежимОтладки();
	КонецЕсли;

	КаталогПроекта = Команда.ЗначениеОпции("workspace");
	Если ПустаяСтрока(КаталогПроекта) Тогда
		КаталогПроекта = ТекущийКаталог();
	КонецЕсли;

	Конвертер = Новый Конвертер(КаталогПроекта);

	КонфигурационныйФайл = Команда.ЗначениеОпции("config");
	Если ЗначениеЗаполнено(КонфигурационныйФайл) Тогда
		ПрочитатьФайлКонфигурации(КонфигурационныйФайл, Конвертер);
	КонецЕсли;

	УстановитьПараметры(Команда, Конвертер);
	
	ФайлПокрытия = Команда.ЗначениеОпции("input");
	ФайлВывода   = Команда.ЗначениеОпции("output");
	
	Конвертер.УстановитьФайлПокрытия(ФайлПокрытия);
	Конвертер.УстановитьФайлВывода(ФайлВывода);
	
	Если Команда.ЗначениеОпции("json") Тогда
		Конвертер.ИспользоватьВнутреннийФормат();
	КонецЕсли;
	
	Конвертер.РазобратьПокрытие();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ПрочитатьФайлКонфигурации(КонфигурационныйФайл, Конвертер)

	МенеджерПараметров = Новый МенеджерПараметров();
	МенеджерПараметров.УстановитьФайлПараметров(КонфигурационныйФайл);
	МенеджерПараметров.ИспользоватьПровайдерJSON();
	МенеджерПараметров.Прочитать();
	
	КаталогИсходниковКонфигурации = МенеджерПараметров.Параметр("Конфигурация.КаталогИсходныхФайлов");
	Если ЗначениеЗаполнено(КаталогИсходниковКонфигурации) Тогда

		ФорматИсходныхФайлов = МенеджерПараметров.Параметр("Конфигурация.Формат", ФорматыИсходныхФайлов.XML);

		Конвертер.УстановитьКаталогИсходниковКонфигурации(КаталогИсходниковКонфигурации, ФорматИсходныхФайлов);

	КонецЕсли;

	МассивРасширений = МенеджерПараметров.Параметр("Расширения");
	ШаблонИмяРасширения         = "Расширения.%1.Имя";
	ШаблонКаталогИсходныхФайлов = "Расширения.%1.КаталогИсходныхФайлов";
	ШаблонФормат                = "Расширения.%1.Формат";
	Для Индекс = 0 По МассивРасширений.Количество() - 1 Цикл

		ИндексСтрокой = XMLСтрока(Индекс);
		ПараметрИмяРасширения         = СтрШаблон(ШаблонИмяРасширения, ИндексСтрокой);
		ПараметрКаталогИсходныхФайлов = СтрШаблон(ШаблонКаталогИсходныхФайлов, ИндексСтрокой);
		ПараметрФормат                = СтрШаблон(ШаблонФормат, ИндексСтрокой);

		ИмяРасширения = МенеджерПараметров.Параметр(ПараметрИмяРасширения);
		КаталогИсходныхФайлов = МенеджерПараметров.Параметр(ПараметрКаталогИсходныхФайлов);
		Формат = МенеджерПараметров.Параметр(ПараметрФормат, ФорматыИсходныхФайлов.XML);

		Конвертер.ДобавитьИсходныеФайлыРасширения(ИмяРасширения, КаталогИсходныхФайлов, Формат);

	КонецЦикла;

КонецПроцедуры

Процедура УстановитьПараметры(Команда, Конвертер)

	КаталогИсходниковКонфигурации = Команда.ЗначениеОпции("sources");
	
	Если ЗначениеЗаполнено(КаталогИсходниковКонфигурации) Тогда
		
		ФорматИсходныхФайлов = Команда.ЗначениеОпции("format");

		Конвертер.УстановитьКаталогИсходниковКонфигурации(КаталогИсходниковКонфигурации, ФорматИсходныхФайлов);
		
	КонецЕсли;

КонецПроцедуры

#КонецОбласти
