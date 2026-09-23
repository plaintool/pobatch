//-----------------------------------------------------------------------------------
//  PoBatch © 2026 by Alexander Tverskoy
//  https://github.com/plaintool/pobatch
//  Licensed under the GNU General Public License, Version 3 (GPL-3.0)
//  You may obtain a copy of the License at https://www.gnu.org/licenses/gpl-3.0.html
//-----------------------------------------------------------------------------------

unit LangCodes;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, stringhelper;

type
  // Record to hold a single language entry
  TLanguageInfo = record
    Code: string;
    Name: string;
  end;

// Fills ADisplay with strings like 'English (en)' and ACodes with pure codes like 'en'
procedure GetLanguageLists(ADisplay: TStrings; ACodes: TStrings);

// Returns the English name for a given code, or an empty string if not found
function GetLanguageNameByCode(const ACode: string): string;

// Returns the ISO 639-1 code for a given English name, or an empty string if not found
function GetLanguageCodeByName(const AName: string): string;

// Shows a language selection dialog and returns the chosen ISO code in ACode; returns True on OK.
function SelectLanguage(var ACode: string; AOptions: TComboQueryOptions = []): boolean;

// Shows a multi-languages selection dialog and returns the chosen ISO code in ACode; returns True on OK.
function SelectLanguages(var ACodes: TStringArray; AOptions: TComboQueryOptions = []): boolean;

implementation

const
  // ISO 639-1 language list with English names and major regional variants
  Languages: array[0..275] of TLanguageInfo = (
    (Code: 'aa'; Name: 'Afar'),
    (Code: 'ab'; Name: 'Abkhazian'),
    (Code: 'ae'; Name: 'Avestan'),
    (Code: 'af'; Name: 'Afrikaans'),
    (Code: 'af-NA'; Name: 'Afrikaans (Namibia)'),
    (Code: 'af-ZA'; Name: 'Afrikaans (South Africa)'),
    (Code: 'ak'; Name: 'Akan'),
    (Code: 'am'; Name: 'Amharic'),
    (Code: 'an'; Name: 'Aragonese'),
    (Code: 'ar'; Name: 'Arabic'),
    (Code: 'ar-AE'; Name: 'Arabic (United Arab Emirates)'),
    (Code: 'ar-BH'; Name: 'Arabic (Bahrain)'),
    (Code: 'ar-DZ'; Name: 'Arabic (Algeria)'),
    (Code: 'ar-EG'; Name: 'Arabic (Egypt)'),
    (Code: 'ar-IQ'; Name: 'Arabic (Iraq)'),
    (Code: 'ar-JO'; Name: 'Arabic (Jordan)'),
    (Code: 'ar-KW'; Name: 'Arabic (Kuwait)'),
    (Code: 'ar-LB'; Name: 'Arabic (Lebanon)'),
    (Code: 'ar-LY'; Name: 'Arabic (Libya)'),
    (Code: 'ar-MA'; Name: 'Arabic (Morocco)'),
    (Code: 'ar-OM'; Name: 'Arabic (Oman)'),
    (Code: 'ar-QA'; Name: 'Arabic (Qatar)'),
    (Code: 'ar-SA'; Name: 'Arabic (Saudi Arabia)'),
    (Code: 'ar-SY'; Name: 'Arabic (Syria)'),
    (Code: 'ar-TN'; Name: 'Arabic (Tunisia)'),
    (Code: 'ar-YE'; Name: 'Arabic (Yemen)'),
    (Code: 'as'; Name: 'Assamese'),
    (Code: 'av'; Name: 'Avaric'),
    (Code: 'ay'; Name: 'Aymara'),
    (Code: 'az'; Name: 'Azerbaijani'),
    (Code: 'ba'; Name: 'Bashkir'),
    (Code: 'be'; Name: 'Belarusian'),
    (Code: 'bg'; Name: 'Bulgarian'),
    (Code: 'bh'; Name: 'Bihari languages'),
    (Code: 'bi'; Name: 'Bislama'),
    (Code: 'bm'; Name: 'Bambara'),
    (Code: 'bn'; Name: 'Bengali'),
    (Code: 'bn-BD'; Name: 'Bengali (Bangladesh)'),
    (Code: 'bn-IN'; Name: 'Bengali (India)'),
    (Code: 'bo'; Name: 'Tibetan'),
    (Code: 'br'; Name: 'Breton'),
    (Code: 'bs'; Name: 'Bosnian'),
    (Code: 'ca'; Name: 'Catalan; Valencian'),
    (Code: 'ca-AD'; Name: 'Catalan (Andorra)'),
    (Code: 'ca-ES'; Name: 'Catalan (Spain)'),
    (Code: 'ce'; Name: 'Chechen'),
    (Code: 'ch'; Name: 'Chamorro'),
    (Code: 'co'; Name: 'Corsican'),
    (Code: 'cr'; Name: 'Cree'),
    (Code: 'cs'; Name: 'Czech'),
    (Code: 'cu'; Name: 'Church Slavonic'),
    (Code: 'cv'; Name: 'Chuvash'),
    (Code: 'cy'; Name: 'Welsh'),
    (Code: 'da'; Name: 'Danish'),
    (Code: 'de'; Name: 'German'),
    (Code: 'de-AT'; Name: 'German (Austria)'),
    (Code: 'de-BE'; Name: 'German (Belgium)'),
    (Code: 'de-CH'; Name: 'German (Switzerland)'),
    (Code: 'de-DE'; Name: 'German (Germany)'),
    (Code: 'de-LI'; Name: 'German (Liechtenstein)'),
    (Code: 'de-LU'; Name: 'German (Luxembourg)'),
    (Code: 'dv'; Name: 'Divehi; Dhivehi; Maldivian'),
    (Code: 'dz'; Name: 'Dzongkha'),
    (Code: 'ee'; Name: 'Ewe'),
    (Code: 'el'; Name: 'Greek, Modern (1453-)'),
    (Code: 'el-CY'; Name: 'Greek (Cyprus)'),
    (Code: 'el-GR'; Name: 'Greek (Greece)'),
    (Code: 'en'; Name: 'English'),
    (Code: 'en-AU'; Name: 'English (Australia)'),
    (Code: 'en-BZ'; Name: 'English (Belize)'),
    (Code: 'en-CA'; Name: 'English (Canada)'),
    (Code: 'en-GB'; Name: 'English (United Kingdom)'),
    (Code: 'en-IE'; Name: 'English (Ireland)'),
    (Code: 'en-IN'; Name: 'English (India)'),
    (Code: 'en-JM'; Name: 'English (Jamaica)'),
    (Code: 'en-NZ'; Name: 'English (New Zealand)'),
    (Code: 'en-PH'; Name: 'English (Philippines)'),
    (Code: 'en-SG'; Name: 'English (Singapore)'),
    (Code: 'en-TT'; Name: 'English (Trinidad and Tobago)'),
    (Code: 'en-US'; Name: 'English (United States)'),
    (Code: 'en-ZA'; Name: 'English (South Africa)'),
    (Code: 'en-ZW'; Name: 'English (Zimbabwe)'),
    (Code: 'eo'; Name: 'Esperanto'),
    (Code: 'es'; Name: 'Spanish; Castilian'),
    (Code: 'es-AR'; Name: 'Spanish (Argentina)'),
    (Code: 'es-BO'; Name: 'Spanish (Bolivia)'),
    (Code: 'es-CL'; Name: 'Spanish (Chile)'),
    (Code: 'es-CO'; Name: 'Spanish (Colombia)'),
    (Code: 'es-CR'; Name: 'Spanish (Costa Rica)'),
    (Code: 'es-DO'; Name: 'Spanish (Dominican Republic)'),
    (Code: 'es-EC'; Name: 'Spanish (Ecuador)'),
    (Code: 'es-ES'; Name: 'Spanish (Spain)'),
    (Code: 'es-GT'; Name: 'Spanish (Guatemala)'),
    (Code: 'es-HN'; Name: 'Spanish (Honduras)'),
    (Code: 'es-MX'; Name: 'Spanish (Mexico)'),
    (Code: 'es-NI'; Name: 'Spanish (Nicaragua)'),
    (Code: 'es-PA'; Name: 'Spanish (Panama)'),
    (Code: 'es-PE'; Name: 'Spanish (Peru)'),
    (Code: 'es-PR'; Name: 'Spanish (Puerto Rico)'),
    (Code: 'es-PY'; Name: 'Spanish (Paraguay)'),
    (Code: 'es-SV'; Name: 'Spanish (El Salvador)'),
    (Code: 'es-US'; Name: 'Spanish (United States)'),
    (Code: 'es-UY'; Name: 'Spanish (Uruguay)'),
    (Code: 'es-VE'; Name: 'Spanish (Venezuela)'),
    (Code: 'et'; Name: 'Estonian'),
    (Code: 'eu'; Name: 'Basque'),
    (Code: 'fa'; Name: 'Persian'),
    (Code: 'fa-AF'; Name: 'Persian (Afghanistan)'),
    (Code: 'fa-IR'; Name: 'Persian (Iran)'),
    (Code: 'ff'; Name: 'Fulah'),
    (Code: 'fi'; Name: 'Finnish'),
    (Code: 'fj'; Name: 'Fijian'),
    (Code: 'fo'; Name: 'Faroese'),
    (Code: 'fr'; Name: 'French'),
    (Code: 'fr-BE'; Name: 'French (Belgium)'),
    (Code: 'fr-CA'; Name: 'French (Canada)'),
    (Code: 'fr-CH'; Name: 'French (Switzerland)'),
    (Code: 'fr-FR'; Name: 'French (France)'),
    (Code: 'fr-LU'; Name: 'French (Luxembourg)'),
    (Code: 'fr-MC'; Name: 'French (Monaco)'),
    (Code: 'fy'; Name: 'Western Frisian'),
    (Code: 'ga'; Name: 'Irish'),
    (Code: 'gd'; Name: 'Gaelic; Scottish Gaelic'),
    (Code: 'gl'; Name: 'Galician'),
    (Code: 'gn'; Name: 'Guarani'),
    (Code: 'gu'; Name: 'Gujarati'),
    (Code: 'gv'; Name: 'Manx'),
    (Code: 'ha'; Name: 'Hausa'),
    (Code: 'he'; Name: 'Hebrew'),
    (Code: 'hi'; Name: 'Hindi'),
    (Code: 'ho'; Name: 'Hiri Motu'),
    (Code: 'hr'; Name: 'Croatian'),
    (Code: 'hr-BA'; Name: 'Croatian (Bosnia and Herzegovina)'),
    (Code: 'hr-HR'; Name: 'Croatian (Croatia)'),
    (Code: 'ht'; Name: 'Haitian; Haitian Creole'),
    (Code: 'hu'; Name: 'Hungarian'),
    (Code: 'hy'; Name: 'Armenian'),
    (Code: 'hz'; Name: 'Herero'),
    (Code: 'ia'; Name: 'Interlingua'),
    (Code: 'id'; Name: 'Indonesian'),
    (Code: 'ie'; Name: 'Interlingue; Occidental'),
    (Code: 'ig'; Name: 'Igbo'),
    (Code: 'ii'; Name: 'Sichuan Yi; Nuosu'),
    (Code: 'ik'; Name: 'Inupiaq'),
    (Code: 'io'; Name: 'Ido'),
    (Code: 'is'; Name: 'Icelandic'),
    (Code: 'it'; Name: 'Italian'),
    (Code: 'it-CH'; Name: 'Italian (Switzerland)'),
    (Code: 'it-IT'; Name: 'Italian (Italy)'),
    (Code: 'iu'; Name: 'Inuktitut'),
    (Code: 'ja'; Name: 'Japanese'),
    (Code: 'jv'; Name: 'Javanese'),
    (Code: 'ka'; Name: 'Georgian'),
    (Code: 'kg'; Name: 'Kongo'),
    (Code: 'ki'; Name: 'Kikuyu; Gikuyu'),
    (Code: 'kj'; Name: 'Kuanyama; Kwanyama'),
    (Code: 'kk'; Name: 'Kazakh'),
    (Code: 'kl'; Name: 'Kalaallisut; Greenlandic'),
    (Code: 'km'; Name: 'Central Khmer'),
    (Code: 'kn'; Name: 'Kannada'),
    (Code: 'ko'; Name: 'Korean'),
    (Code: 'kr'; Name: 'Kanuri'),
    (Code: 'ks'; Name: 'Kashmiri'),
    (Code: 'ku'; Name: 'Kurdish'),
    (Code: 'kv'; Name: 'Komi'),
    (Code: 'kw'; Name: 'Cornish'),
    (Code: 'ky'; Name: 'Kirghiz; Kyrgyz'),
    (Code: 'la'; Name: 'Latin'),
    (Code: 'lb'; Name: 'Luxembourgish; Letzeburgesch'),
    (Code: 'lg'; Name: 'Ganda'),
    (Code: 'li'; Name: 'Limburgan; Limburger; Limburgish'),
    (Code: 'ln'; Name: 'Lingala'),
    (Code: 'lo'; Name: 'Lao'),
    (Code: 'lt'; Name: 'Lithuanian'),
    (Code: 'lu'; Name: 'Luba-Katanga'),
    (Code: 'lv'; Name: 'Latvian'),
    (Code: 'mg'; Name: 'Malagasy'),
    (Code: 'mh'; Name: 'Marshallese'),
    (Code: 'mi'; Name: 'Maori'),
    (Code: 'mk'; Name: 'Macedonian'),
    (Code: 'ml'; Name: 'Malayalam'),
    (Code: 'mn'; Name: 'Mongolian'),
    (Code: 'mr'; Name: 'Marathi'),
    (Code: 'ms'; Name: 'Malay'),
    (Code: 'mt'; Name: 'Maltese'),
    (Code: 'my'; Name: 'Burmese'),
    (Code: 'na'; Name: 'Nauru'),
    (Code: 'nb'; Name: 'Bokmål, Norwegian; Norwegian Bokmål'),
    (Code: 'nd'; Name: 'Ndebele, North; North Ndebele'),
    (Code: 'ne'; Name: 'Nepali'),
    (Code: 'ng'; Name: 'Ndonga'),
    (Code: 'nl'; Name: 'Dutch; Flemish'),
    (Code: 'nl-BE'; Name: 'Dutch (Belgium)'),
    (Code: 'nl-NL'; Name: 'Dutch (Netherlands)'),
    (Code: 'nn'; Name: 'Norwegian Nynorsk; Nynorsk, Norwegian'),
    (Code: 'no'; Name: 'Norwegian'),
    (Code: 'nr'; Name: 'Ndebele, South; South Ndebele'),
    (Code: 'nv'; Name: 'Navajo; Navaho'),
    (Code: 'ny'; Name: 'Chichewa; Chewa; Nyanja'),
    (Code: 'oc'; Name: 'Occitan (post 1500)'),
    (Code: 'oj'; Name: 'Ojibwa'),
    (Code: 'om'; Name: 'Oromo'),
    (Code: 'or'; Name: 'Oriya'),
    (Code: 'os'; Name: 'Ossetian; Ossetic'),
    (Code: 'pa'; Name: 'Panjabi; Punjabi'),
    (Code: 'pi'; Name: 'Pali'),
    (Code: 'pl'; Name: 'Polish'),
    (Code: 'ps'; Name: 'Pushto; Pashto'),
    (Code: 'pt'; Name: 'Portuguese'),
    (Code: 'pt-BR'; Name: 'Portuguese (Brazil)'),
    (Code: 'pt-PT'; Name: 'Portuguese (Portugal)'),
    (Code: 'qu'; Name: 'Quechua'),
    (Code: 'rm'; Name: 'Romansh'),
    (Code: 'rn'; Name: 'Rundi'),
    (Code: 'ro'; Name: 'Romanian'),
    (Code: 'ro-MD'; Name: 'Romanian (Moldova)'),
    (Code: 'ru'; Name: 'Russian'),
    (Code: 'rw'; Name: 'Kinyarwanda'),
    (Code: 'sa'; Name: 'Sanskrit'),
    (Code: 'sc'; Name: 'Sardinian'),
    (Code: 'sd'; Name: 'Sindhi'),
    (Code: 'se'; Name: 'Northern Sami'),
    (Code: 'sg'; Name: 'Sango'),
    (Code: 'si'; Name: 'Sinhala; Sinhalese'),
    (Code: 'sk'; Name: 'Slovak'),
    (Code: 'sl'; Name: 'Slovenian'),
    (Code: 'sm'; Name: 'Samoan'),
    (Code: 'sn'; Name: 'Shona'),
    (Code: 'so'; Name: 'Somali'),
    (Code: 'sq'; Name: 'Albanian'),
    (Code: 'sr'; Name: 'Serbian'),
    (Code: 'sr-BA'; Name: 'Serbian (Bosnia and Herzegovina)'),
    (Code: 'sr-RS'; Name: 'Serbian (Serbia)'),
    (Code: 'ss'; Name: 'Swati'),
    (Code: 'st'; Name: 'Sotho, Southern'),
    (Code: 'su'; Name: 'Sundanese'),
    (Code: 'sv'; Name: 'Swedish'),
    (Code: 'sv-FI'; Name: 'Swedish (Finland)'),
    (Code: 'sv-SE'; Name: 'Swedish (Sweden)'),
    (Code: 'sw'; Name: 'Swahili'),
    (Code: 'ta'; Name: 'Tamil'),
    (Code: 'ta-IN'; Name: 'Tamil (India)'),
    (Code: 'ta-LK'; Name: 'Tamil (Sri Lanka)'),
    (Code: 'te'; Name: 'Telugu'),
    (Code: 'tg'; Name: 'Tajik'),
    (Code: 'th'; Name: 'Thai'),
    (Code: 'ti'; Name: 'Tigrinya'),
    (Code: 'tk'; Name: 'Turkmen'),
    (Code: 'tl'; Name: 'Tagalog'),
    (Code: 'tn'; Name: 'Tswana'),
    (Code: 'to'; Name: 'Tonga (Tonga Islands)'),
    (Code: 'tr'; Name: 'Turkish'),
    (Code: 'ts'; Name: 'Tsonga'),
    (Code: 'tt'; Name: 'Tatar'),
    (Code: 'tw'; Name: 'Twi'),
    (Code: 'ty'; Name: 'Tahitian'),
    (Code: 'ug'; Name: 'Uighur; Uyghur'),
    (Code: 'uk'; Name: 'Ukrainian'),
    (Code: 'ur'; Name: 'Urdu'),
    (Code: 'uz'; Name: 'Uzbek'),
    (Code: 've'; Name: 'Venda'),
    (Code: 'vi'; Name: 'Vietnamese'),
    (Code: 'vo'; Name: 'Volapük'),
    (Code: 'wa'; Name: 'Walloon'),
    (Code: 'wo'; Name: 'Wolof'),
    (Code: 'xh'; Name: 'Xhosa'),
    (Code: 'yi'; Name: 'Yiddish'),
    (Code: 'yo'; Name: 'Yoruba'),
    (Code: 'za'; Name: 'Zhuang; Chuang'),
    (Code: 'zh'; Name: 'Chinese'),
    (Code: 'zh-CN'; Name: 'Chinese (Simplified, China)'),
    (Code: 'zh-HK'; Name: 'Chinese (Traditional, Hong Kong)'),
    (Code: 'zh-MO'; Name: 'Chinese (Traditional, Macao)'),
    (Code: 'zh-SG'; Name: 'Chinese (Simplified, Singapore)'),
    (Code: 'zh-TW'; Name: 'Chinese (Traditional, Taiwan)'),
    (Code: 'zu'; Name: 'Zulu')
    );

procedure GetLanguageLists(ADisplay: TStrings; ACodes: TStrings);
var
  I: integer = 0;
begin
  if (ADisplay = nil) or (ACodes = nil) then
    Exit;
  ADisplay.BeginUpdate;
  ACodes.BeginUpdate;
  try
    ADisplay.Clear;
    ACodes.Clear;
    for I := Low(Languages) to High(Languages) do
    begin
      ADisplay.Add(Format('%s (%s)', [Languages[I].Name, Languages[I].Code]));
      ACodes.Add(Languages[I].Code);
    end;
  finally
    ADisplay.EndUpdate;
    ACodes.EndUpdate;
  end;
end;

function GetLanguageNameByCode(const ACode: string): string;
var
  I: integer = 0;
  TargetCode: string = '';
begin
  Result := '';
  TargetCode := LowerCase(Trim(ACode));
  for I := Low(Languages) to High(Languages) do
    if LowerCase(Languages[I].Code) = TargetCode then
    begin
      Result := Languages[I].Name;
      Break;
    end;
end;

function GetLanguageCodeByName(const AName: string): string;
var
  I: integer = 0;
  TargetName: string = '';
begin
  Result := '';
  TargetName := LowerCase(Trim(AName));
  for I := Low(Languages) to High(Languages) do
    if LowerCase(Languages[I].Name) = TargetName then
    begin
      Result := Languages[I].Code;
      Break;
    end;
end;

function SelectLanguage(var ACode: string; AOptions: TComboQueryOptions = []): boolean;
var
  DisplayList: TStringList = nil;
  CodeList: TStringList = nil;
begin
  Result := False;
  DisplayList := TStringList.Create;
  CodeList := TStringList.Create;
  try
    GetLanguageLists(DisplayList, CodeList);
    Result := ComboQueryLite('Select language', 'Choose interface language or type a language code', DisplayList,
      CodeList, ACode, AOptions);
  finally
    DisplayList.Free;
    CodeList.Free;
  end;
end;

function SelectLanguages(var ACodes: TStringArray; AOptions: TComboQueryOptions = []): boolean;
var
  DisplayList: TStringList = nil;
  CodeList: TStringList = nil;
begin
  Result := False;
  DisplayList := TStringList.Create;
  CodeList := TStringList.Create;
  try
    GetLanguageLists(DisplayList, CodeList);
    Result := CheckListQueryLite('Select languages', 'Choose interface languages', DisplayList, CodeList, ACodes, AOptions);
  finally
    DisplayList.Free;
    CodeList.Free;
  end;
end;

end.
