#Использовать configor
#Использовать "../../../pkg/converter"
#Использовать "../internal/localization"

Перем Лог;
Перем ЛокализованныеСтроки;

#Область КомандаПриложения

Процедура ОписаниеКоманды(Команда) Экспорт
	
	Команда.Опция("i input", "", ЛокализованныеСтроки.ИсходныйФайл)
	.ТСтрока()
	.Обязательный();
	
	Команда.Опция("o output", "", ЛокализованныеСтроки.ФайлРезультата)
	.ТСтрока()
	.Обязательный();
	
	Команда.Опция("w workspace", "", ЛокализованныеСтроки.КаталогПроекта)
	.ТСтрока();
	
	Команда.Опция("s sources", "", ЛокализованныеСтроки.КаталогИсходников)
	.ТСтрока();
	
	Команда.Опция("f format", "XML", ЛокализованныеСтроки.ФорматИсходников)
	.ТСтрока();
	
	Команда.Опция("c config", "", ЛокализованныеСтроки.КонфигурационныйФайл)
	.ТСтрока();
	
	Команда.Опция("j json", Ложь, ЛокализованныеСтроки.ВнутреннийФормат)
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
	ФайлВывода = Команда.ЗначениеОпции("output");
	
	Конвертер.УстановитьФайлПокрытия(ФайлПокрытия);
	Конвертер.УстановитьФайлВывода(ФайлВывода);
	
	Если Команда.ЗначениеОпции("json") Тогда
		Конвертер.ИспользоватьВнутреннийФормат();
	КонецЕсли;
	
	Конвертер.РазобратьПокрытие();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ПриСозданииОбъекта() Экспорт
	Лог = ПараметрыПриложения.Лог();
	ЛокализованныеСтроки = ЛокализованныеРесурсыКомандаКонвертировать.ЛокализованныеСтроки();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ПрочитатьФайлКонфигурации(КонфигурационныйФайл, Конвертер)
	
	МенеджерПараметров = Новый МенеджерПараметров();
	МенеджерПараметров.УстановитьФайлПараметров(КонфигурационныйФайл);
	МенеджерПараметров.ИспользоватьПровайдерJSON();
	МенеджерПараметров.Прочитать();
		
	ПрочитатьПараметрыКонвертацииКонфигурации(МенеджерПараметров, Конвертер);	
	ПрочитатьПараметрыКонвертацииРасширений(МенеджерПараметров, Конвертер);
	ПрочитатьПараметрыКонвертацииВнешнихМодулей(МенеджерПараметров, Конвертер);
	
КонецПроцедуры

Процедура ПрочитатьПараметрыКонвертацииКонфигурации(МенеджерПараметров, Конвертер)
	
	КаталогИсходниковКонфигурации = МенеджерПараметров.Параметр("Configuration.SourcePath");
	Если ЗначениеЗаполнено(КаталогИсходниковКонфигурации) Тогда
		
		ФорматИсходныхФайлов = МенеджерПараметров.Параметр("Configuration.SourceFormat", ФорматыИсходныхФайлов.XML);
		
		Конвертер.УстановитьКаталогИсходниковКонфигурации(КаталогИсходниковКонфигурации, ФорматИсходныхФайлов);
		
	КонецЕсли;

КонецПроцедуры

Процедура ПрочитатьПараметрыКонвертацииРасширений(МенеджерПараметров, Конвертер)
	
	Расширения = МенеджерПараметров.Параметр("Extensions");
	Если ТипЗнч(Расширения) <> Тип("Массив") Тогда
		Возврат;
	КонецЕсли;
	
	ШаблонИмяРасширения         = "Extensions.%1.Name";
	ШаблонКаталогИсходныхФайлов = "Extensions.%1.SourcePath";
	ШаблонФормат                = "Extensions.%1.SourceFormat";
	Для Индекс = 0 По Расширения.Количество() - 1 Цикл
		
		ИндексСтрокой = XMLСтрока(Индекс);
		ПараметрИмяРасширения         = СтрШаблон(ШаблонИмяРасширения, ИндексСтрокой);
		ПараметрКаталогИсходныхФайлов = СтрШаблон(ШаблонКаталогИсходныхФайлов, ИндексСтрокой);
		ПараметрФормат                = СтрШаблон(ШаблонФормат, ИндексСтрокой);
		
		ИмяРасширения         = МенеджерПараметров.Параметр(ПараметрИмяРасширения);
		КаталогИсходныхФайлов = МенеджерПараметров.Параметр(ПараметрКаталогИсходныхФайлов);
		Формат                = МенеджерПараметров.Параметр(ПараметрФормат, ФорматыИсходныхФайлов.XML);
		
		Конвертер.ДобавитьИсходныеФайлыРасширения(ИмяРасширения, КаталогИсходныхФайлов, Формат);
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ПрочитатьПараметрыКонвертацииВнешнихМодулей(МенеджерПараметров, Конвертер)
	
	ВнешниеОтчетыИОбработки = МенеджерПараметров.Параметр("ExternalReportsAndDataProcessors");
	Если ТипЗнч(ВнешниеОтчетыИОбработки) <> Тип("Массив") Тогда
		Возврат;
	КонецЕсли;
	
	ШаблонФайлОтчетаОбработки = "ExternalReportsAndDataProcessors.%1.URL";
	ШаблонТипURL = "ExternalReportsAndDataProcessors.%1.URLType";
	ШаблонКаталогИсходныхФайлов = "ExternalReportsAndDataProcessors.%1.SourcePath";
	ШаблонФормат = "ExternalReportsAndDataProcessors.%1.SourceFormat";
	Для Индекс = 0 По ВнешниеОтчетыИОбработки.Количество() - 1 Цикл
		
		ИндексСтрокой = XMLСтрока(Индекс);
		ПараметрФайлОтчетаОбработки = СтрШаблон(ШаблонФайлОтчетаОбработки, ИндексСтрокой);
		ПараметрТипURL = СтрШаблон(ШаблонТипURL, ИндексСтрокой);
		ПараметрКаталогИсходныхФайлов = СтрШаблон(ШаблонКаталогИсходныхФайлов, ИндексСтрокой);
		ПараметрФормат = СтрШаблон(ШаблонФормат, ИндексСтрокой);
		
		ФайлОтчетаОбработки = МенеджерПараметров.Параметр(ПараметрФайлОтчетаОбработки);
		КаталогИсходныхФайлов = МенеджерПараметров.Параметр(ПараметрКаталогИсходныхФайлов);
		Формат = МенеджерПараметров.Параметр(ПараметрФормат, ФорматыИсходныхФайлов.XML);
		ТипURL = МенеджерПараметров.Параметр(ПараметрТипURL, "file");
		
		Если ТипURL = "file" Тогда
			URLВнешнегоМодуля = СтрШаблон("file://%1", ФайлОтчетаОбработки);
		Иначе
			URLВнешнегоМодуля = ФайлОтчетаОбработки;
		КонецЕсли;
		
		Конвертер.ДобавитьИсходныеФайлыВнешнегоМодуля(URLВнешнегоМодуля, КаталогИсходныхФайлов, Формат);
		
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
