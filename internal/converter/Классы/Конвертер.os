
#Использовать "../../csv"
#Использовать "../../coverage"

Перем Лог;
Перем ФайлПокрытия;
Перем ФайлВывода;
Перем КаталогПроекта;
Перем КонвертерКонфигурации;
Перем КонвертерыРасширений;
Перем КонвертерыВнешнихМодулей;
Перем ИспользоватьВнутреннийФормат;

#Область ПрограммныйИнтерфейс

Процедура УстановитьКаталогПроекта(ПараметрКаталогПроекта) Экспорт
	КаталогПроекта = ПараметрКаталогПроекта;
КонецПроцедуры

Процедура УстановитьФайлПокрытия(ПараметрФайлПокрытия) Экспорт
	ФайлПокрытия = ПараметрФайлПокрытия;
КонецПроцедуры

Процедура УстановитьФайлВывода(ПараметрФайлВывода) Экспорт
	ФайлВывода = ПараметрФайлВывода;
КонецПроцедуры

Процедура ИспользоватьВнутреннийФормат() Экспорт
	ИспользоватьВнутреннийФормат = Истина;
КонецПроцедуры

Процедура УстановитьКаталогИсходниковКонфигурации(КаталогИсходныхФайлов, ФорматИсходныхФайлов) Экспорт
	КонвертерКонфигурации = Новый КонвертерИменМодулей(КаталогПроекта, КаталогИсходныхФайлов, ФорматИсходныхФайлов);
КонецПроцедуры

Процедура ДобавитьИсходныеФайлыРасширения(ИмяРасширения, КаталогИсходныхФайлов, ФорматИсходныхФайлов) Экспорт

	КонвертерРасширения = Новый КонвертерИменМодулей(КаталогПроекта, КаталогИсходныхФайлов, ФорматИсходныхФайлов);
	КонвертерыРасширений.Вставить(ИмяРасширения, КонвертерРасширения);

КонецПроцедуры

Процедура ДобавитьИсходныеФайлыВнешнегоМодуля(URLМодуля, КаталогИсходныхФайлов, ФорматИсходныхФайлов) Экспорт

	КонвертерВнешнегоМодуля = Новый КонвертерИменМодулей(КаталогПроекта, КаталогИсходныхФайлов, ФорматИсходныхФайлов);
	КонвертерыВнешнихМодулей.Вставить(URLМодуля, КонвертерВнешнегоМодуля);

КонецПроцедуры

Процедура РазобратьПокрытие() Экспорт

	РазбиратьРасширения = (КонвертерыРасширений.Количество() > 0);
	РазбиратьВнешниеМодули = (КонвертерыВнешнихМодулей.Количество() > 0);
	ДанныеПокрытия = Новый Соответствие;

	ЧтениеCSV = Новый ЧтениеCSV();
	ЧтениеCSV.УстановитьФайл(ФайлПокрытия);
	ЧтениеCSV.Прочитать();

	ПоляЗаголовка = ЧтениеCSV.ТекущееЗначение();
	ЧтениеCSV.УстановитьПоляЗаголовка(ПоляЗаголовка);

	Пока ЧтениеCSV.Прочитать() Цикл

		СтрокаПокрытия = ЧтениеCSV.ТекущиеЗначенияПолей(Истина);
		ПрограммныйМодуль = Неопределено;

		ТипКонтейнера = СтрокаПокрытия.ModuleName;
		Если ТипКонтейнера = ТипыКонтейнеровПрограммныхМодулей.МодульКонфигурации Тогда
			
			ПрограммныйМодуль = НайтиМодульКонфигурации(СтрокаПокрытия);
		
		ИначеЕсли РазбиратьРасширения И ТипКонтейнера = ТипыКонтейнеровПрограммныхМодулей.МодульРасширения Тогда
			
			ПрограммныйМодуль = НайтиМодульРасширения(СтрокаПокрытия);
		
		ИначеЕсли РазбиратьВнешниеМодули И ТипКонтейнера = ТипыКонтейнеровПрограммныхМодулей.ВнешнийМодуль Тогда

			ПрограммныйМодуль = НайтиВнешнийМодуль(СтрокаПокрытия);
	
		Иначе
			Продолжить;
		КонецЕсли;
		
		Если ПрограммныйМодуль = Неопределено Тогда
			Продолжить;
		КонецЕсли;

		ДобавитьПокрытиеJSON(ДанныеПокрытия, СтрокаПокрытия, ПрограммныйМодуль);

	КонецЦикла;

	ЧтениеCSV.Закрыть();

	Если ИспользоватьВнутреннийФормат Тогда
		ФорматДанныеПокрытия.ЗаписатьДанныеПокрытияJSON(ФайлВывода, ДанныеПокрытия);
	Иначе
		ФорматДанныеПокрытия.ЗаписатьДанныеПокрытияXML(ФайлВывода, ДанныеПокрытия);
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ПриСозданииОбъекта(ПараметрКаталогПроекта) Экспорт
	КаталогПроекта = ПараметрКаталогПроекта;
	КонвертерыРасширений = Новый Соответствие;
	КонвертерыВнешнихМодулей = Новый Соответствие;
	ИспользоватьВнутреннийФормат = Ложь;
	Лог = ПараметрыПриложения.Лог();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция НайтиМодульКонфигурации(СтрокаПокрытия)
	
	ВидПрограммногоМодуля = СтрокаПокрытия.PropertyId;
	ИДПрограммногоМодуля = СтрокаПокрытия.ObjectId;

	Если КонвертерКонфигурации = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;

	Возврат КонвертерКонфигурации.НайтиПрограммныйМодуль(ВидПрограммногоМодуля, ИДПрограммногоМодуля);

КонецФункции

Функция НайтиМодульРасширения(СтрокаПокрытия)

	ИмяРасширения = СтрокаПокрытия.ExtentionName;
	КонвертерРасширения = КонвертерыРасширений[ИмяРасширения];

	Если КонвертерРасширения = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ВидПрограммногоМодуля  = СтрокаПокрытия.PropertyId;
	ИДПрограммногоМодуля   = СтрокаПокрытия.ObjectId;
	Возврат КонвертерРасширения.НайтиПрограммныйМодуль(ВидПрограммногоМодуля, ИДПрограммногоМодуля);
	
КонецФункции

Функция НайтиВнешнийМодуль(СтрокаПокрытия)

	URLМодуля = СтрокаПокрытия.URL;
	КонвертерВнешнегоМодуля = КонвертерыВнешнихМодулей[URLМодуля];
	Если КонвертерВнешнегоМодуля = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ВидПрограммногоМодуля  = СтрокаПокрытия.PropertyId;
	ИДПрограммногоМодуля   = СтрокаПокрытия.ObjectId;
	Возврат КонвертерВнешнегоМодуля.НайтиПрограммныйМодуль(ВидПрограммногоМодуля, ИДПрограммногоМодуля);
	
КонецФункции

Процедура ДобавитьПокрытиеJSON(ДанныеПокрытия, СтрокаПокрытия, ПрограммныйМодуль)

	ДанныеПокрытияМодуля = ДанныеПокрытия.Получить(ПрограммныйМодуль.Идентификатор);
	Если ДанныеПокрытияМодуля = Неопределено Тогда
		
		ДанныеПокрытияМодуля = ФорматДанныеПокрытия.НовыйДанныеПокрытияМодуля();
		ДанныеПокрытияМодуля.ModuleId      = ПрограммныйМодуль.Идентификатор;
		ДанныеПокрытияМодуля.SourcePath    = ПрограммныйМодуль.Путь;
		ДанныеПокрытияМодуля.ObjectId      = СтрокаПокрытия.ObjectId;
		ДанныеПокрытияМодуля.PropertyId    = СтрокаПокрытия.PropertyId;
		ДанныеПокрытияМодуля.ModuleName    = СтрокаПокрытия.ModuleName;
		ДанныеПокрытияМодуля.ExtentionName = СтрокаПокрытия.ExtentionName;
		ДанныеПокрытияМодуля.URL           = СтрокаПокрытия.URL;
		
		ДанныеПокрытия.Вставить(ПрограммныйМодуль.Идентификатор, ДанныеПокрытияМодуля);
	
	КонецЕсли;

	ДанныеПокрытияМодуля.LineNo.Вставить(СтрокаПокрытия.LineNo, Истина);

КонецПроцедуры

#КонецОбласти
