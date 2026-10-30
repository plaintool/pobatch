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
  Classes, SysUtils, StringHelper;

type
  // Record to hold a single language entry
  TLanguageInfo = record
    Code: string;
    Name: string;
    PluralForms: string;
  end;

// Fills ADisplay with strings like 'English (en)' and ACodes with pure codes like 'en'
procedure GetLanguageLists(ADisplay: TStrings; ACodes: TStrings);

// Returns the English name for a given code, or an empty string if not found
function GetLanguageNameByCode(const ACode: string): string;

// Returns the ISO 639-1 code for a given English name, or an empty string if not found
function GetLanguageCodeByName(const AName: string): string;

// Returns the gettext Plural-Forms expression for the given code,
// or an empty string when the code is unknown
function GetLanguagePluralForms(const ACode: string): string;

// Fills AList with every distinct Plural-Forms expression found in the
// language table, in the order of first occurrence
procedure GetAllPluralForms(AList: TStrings);

// Shows a language selection dialog and returns the chosen ISO code in ACode; returns True on OK.
function SelectLanguage(var ACode: string; AOptions: TComboQueryOptions = []): boolean;

// Shows a multi-languages selection dialog and returns the chosen ISO code in ACode; returns True on OK.
function SelectLanguages(var ACodes: TStringArray; AOptions: TComboQueryOptions = []): boolean;

implementation

const
  // ISO 639-1 language list with English names, major regional variants, and gettext plural forms
  Languages: array[0..275] of TLanguageInfo = (
    (Code: 'aa'; Name: 'Afar'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ab'; Name: 'Abkhazian'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ae'; Name: 'Avestan'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'af'; Name: 'Afrikaans'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'af-NA'; Name: 'Afrikaans (Namibia)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'af-ZA'; Name: 'Afrikaans (South Africa)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ak'; Name: 'Akan'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'am'; Name: 'Amharic'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'an'; Name: 'Aragonese'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ar'; Name: 'Arabic'; PluralForms:
    'nplurals=6; plural=n==0 ? 0 : n==1 ? 1 : n==2 ? 2 : n%100>=3 && n%100<=10 ? 3 : n%100>=11 ? 4 : 5;'),
    (Code: 'ar-AE'; Name: 'Arabic (United Arab Emirates)';
    PluralForms: 'nplurals=6; plural=n==0 ? 0 : n==1 ? 1 : n==2 ? 2 : n%100>=3 && n%100<=10 ? 3 : n%100>=11 ? 4 : 5;'),
    (Code: 'ar-BH'; Name: 'Arabic (Bahrain)';
    PluralForms: 'nplurals=6; plural=n==0 ? 0 : n==1 ? 1 : n==2 ? 2 : n%100>=3 && n%100<=10 ? 3 : n%100>=11 ? 4 : 5;'),
    (Code: 'ar-DZ'; Name: 'Arabic (Algeria)';
    PluralForms: 'nplurals=6; plural=n==0 ? 0 : n==1 ? 1 : n==2 ? 2 : n%100>=3 && n%100<=10 ? 3 : n%100>=11 ? 4 : 5;'),
    (Code: 'ar-EG'; Name: 'Arabic (Egypt)';
    PluralForms: 'nplurals=6; plural=n==0 ? 0 : n==1 ? 1 : n==2 ? 2 : n%100>=3 && n%100<=10 ? 3 : n%100>=11 ? 4 : 5;'),
    (Code: 'ar-IQ'; Name: 'Arabic (Iraq)';
    PluralForms: 'nplurals=6; plural=n==0 ? 0 : n==1 ? 1 : n==2 ? 2 : n%100>=3 && n%100<=10 ? 3 : n%100>=11 ? 4 : 5;'),
    (Code: 'ar-JO'; Name: 'Arabic (Jordan)';
    PluralForms: 'nplurals=6; plural=n==0 ? 0 : n==1 ? 1 : n==2 ? 2 : n%100>=3 && n%100<=10 ? 3 : n%100>=11 ? 4 : 5;'),
    (Code: 'ar-KW'; Name: 'Arabic (Kuwait)';
    PluralForms: 'nplurals=6; plural=n==0 ? 0 : n==1 ? 1 : n==2 ? 2 : n%100>=3 && n%100<=10 ? 3 : n%100>=11 ? 4 : 5;'),
    (Code: 'ar-LB'; Name: 'Arabic (Lebanon)';
    PluralForms: 'nplurals=6; plural=n==0 ? 0 : n==1 ? 1 : n==2 ? 2 : n%100>=3 && n%100<=10 ? 3 : n%100>=11 ? 4 : 5;'),
    (Code: 'ar-LY'; Name: 'Arabic (Libya)';
    PluralForms: 'nplurals=6; plural=n==0 ? 0 : n==1 ? 1 : n==2 ? 2 : n%100>=3 && n%100<=10 ? 3 : n%100>=11 ? 4 : 5;'),
    (Code: 'ar-MA'; Name: 'Arabic (Morocco)';
    PluralForms: 'nplurals=6; plural=n==0 ? 0 : n==1 ? 1 : n==2 ? 2 : n%100>=3 && n%100<=10 ? 3 : n%100>=11 ? 4 : 5;'),
    (Code: 'ar-OM'; Name: 'Arabic (Oman)';
    PluralForms: 'nplurals=6; plural=n==0 ? 0 : n==1 ? 1 : n==2 ? 2 : n%100>=3 && n%100<=10 ? 3 : n%100>=11 ? 4 : 5;'),
    (Code: 'ar-QA'; Name: 'Arabic (Qatar)';
    PluralForms: 'nplurals=6; plural=n==0 ? 0 : n==1 ? 1 : n==2 ? 2 : n%100>=3 && n%100<=10 ? 3 : n%100>=11 ? 4 : 5;'),
    (Code: 'ar-SA'; Name: 'Arabic (Saudi Arabia)';
    PluralForms: 'nplurals=6; plural=n==0 ? 0 : n==1 ? 1 : n==2 ? 2 : n%100>=3 && n%100<=10 ? 3 : n%100>=11 ? 4 : 5;'),
    (Code: 'ar-SY'; Name: 'Arabic (Syria)';
    PluralForms: 'nplurals=6; plural=n==0 ? 0 : n==1 ? 1 : n==2 ? 2 : n%100>=3 && n%100<=10 ? 3 : n%100>=11 ? 4 : 5;'),
    (Code: 'ar-TN'; Name: 'Arabic (Tunisia)';
    PluralForms: 'nplurals=6; plural=n==0 ? 0 : n==1 ? 1 : n==2 ? 2 : n%100>=3 && n%100<=10 ? 3 : n%100>=11 ? 4 : 5;'),
    (Code: 'ar-YE'; Name: 'Arabic (Yemen)';
    PluralForms: 'nplurals=6; plural=n==0 ? 0 : n==1 ? 1 : n==2 ? 2 : n%100>=3 && n%100<=10 ? 3 : n%100>=11 ? 4 : 5;'),
    (Code: 'as'; Name: 'Assamese'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'av'; Name: 'Avaric'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ay'; Name: 'Aymara'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'az'; Name: 'Azerbaijani'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ba'; Name: 'Bashkir'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'be'; Name: 'Belarusian'; PluralForms:
    'nplurals=3; plural=n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<12 || n%100>14) ? 1 : 2;'),
    (Code: 'bg'; Name: 'Bulgarian'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'bh'; Name: 'Bihari languages'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'bi'; Name: 'Bislama'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'bm'; Name: 'Bambara'; PluralForms: 'nplurals=1; plural=0;'),
    (Code: 'bn'; Name: 'Bengali'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'bn-BD'; Name: 'Bengali (Bangladesh)'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'bn-IN'; Name: 'Bengali (India)'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'bo'; Name: 'Tibetan'; PluralForms: 'nplurals=1; plural=0;'),
    (Code: 'br'; Name: 'Breton'; PluralForms:
    'nplurals=5; plural=n%10==1 && n%100!=11 && n%100!=71 && n%100!=91 ? 0 : n%10==2 && n%100!=12 && n%100!=72 && n%100!=92 ? 1 : (n%10==3 || n%10==4 || n%10==9) && (n%100<10 || n%100>19) && (n%100<70 || n%100>79) && (n%100<90 || n%100>99) ? 2 : n != 0 && n%1000000==0 ? 3 : 4;'),
    (Code: 'bs'; Name: 'Bosnian'; PluralForms:
    'nplurals=3; plural=n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<12 || n%100>14) ? 1 : 2;'),
    (Code: 'ca'; Name: 'Catalan; Valencian'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ca-AD'; Name: 'Catalan (Andorra)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ca-ES'; Name: 'Catalan (Spain)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ce'; Name: 'Chechen'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ch'; Name: 'Chamorro'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'co'; Name: 'Corsican'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'cr'; Name: 'Cree'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'cs'; Name: 'Czech'; PluralForms: 'nplurals=3; plural=(n==1) ? 0 : (n>=2 && n<=4) ? 1 : 2;'),
    (Code: 'cu'; Name: 'Church Slavonic'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'cv'; Name: 'Chuvash'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'cy'; Name: 'Welsh'; PluralForms: 'nplurals=6; plural=n==0 ? 0 : n==1 ? 1 : n==2 ? 2 : n==3 ? 3 : n==6 ? 4 : 5;'),
    (Code: 'da'; Name: 'Danish'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'de'; Name: 'German'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'de-AT'; Name: 'German (Austria)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'de-BE'; Name: 'German (Belgium)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'de-CH'; Name: 'German (Switzerland)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'de-DE'; Name: 'German (Germany)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'de-LI'; Name: 'German (Liechtenstein)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'de-LU'; Name: 'German (Luxembourg)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'dv'; Name: 'Divehi; Dhivehi; Maldivian'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'dz'; Name: 'Dzongkha'; PluralForms: 'nplurals=1; plural=0;'),
    (Code: 'ee'; Name: 'Ewe'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'el'; Name: 'Greek, Modern (1453-)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'el-CY'; Name: 'Greek (Cyprus)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'el-GR'; Name: 'Greek (Greece)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'en'; Name: 'English'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'en-AU'; Name: 'English (Australia)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'en-BZ'; Name: 'English (Belize)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'en-CA'; Name: 'English (Canada)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'en-GB'; Name: 'English (United Kingdom)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'en-IE'; Name: 'English (Ireland)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'en-IN'; Name: 'English (India)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'en-JM'; Name: 'English (Jamaica)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'en-NZ'; Name: 'English (New Zealand)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'en-PH'; Name: 'English (Philippines)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'en-SG'; Name: 'English (Singapore)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'en-TT'; Name: 'English (Trinidad and Tobago)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'en-US'; Name: 'English (United States)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'en-ZA'; Name: 'English (South Africa)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'en-ZW'; Name: 'English (Zimbabwe)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'eo'; Name: 'Esperanto'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'es'; Name: 'Spanish; Castilian'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'es-AR'; Name: 'Spanish (Argentina)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'es-BO'; Name: 'Spanish (Bolivia)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'es-CL'; Name: 'Spanish (Chile)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'es-CO'; Name: 'Spanish (Colombia)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'es-CR'; Name: 'Spanish (Costa Rica)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'es-DO'; Name: 'Spanish (Dominican Republic)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'es-EC'; Name: 'Spanish (Ecuador)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'es-ES'; Name: 'Spanish (Spain)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'es-GT'; Name: 'Spanish (Guatemala)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'es-HN'; Name: 'Spanish (Honduras)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'es-MX'; Name: 'Spanish (Mexico)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'es-NI'; Name: 'Spanish (Nicaragua)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'es-PA'; Name: 'Spanish (Panama)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'es-PE'; Name: 'Spanish (Peru)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'es-PR'; Name: 'Spanish (Puerto Rico)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'es-PY'; Name: 'Spanish (Paraguay)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'es-SV'; Name: 'Spanish (El Salvador)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'es-US'; Name: 'Spanish (United States)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'es-UY'; Name: 'Spanish (Uruguay)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'es-VE'; Name: 'Spanish (Venezuela)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'et'; Name: 'Estonian'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'eu'; Name: 'Basque'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'fa'; Name: 'Persian'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'fa-AF'; Name: 'Persian (Afghanistan)'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'fa-IR'; Name: 'Persian (Iran)'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'ff'; Name: 'Fulah'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'fi'; Name: 'Finnish'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'fj'; Name: 'Fijian'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'fo'; Name: 'Faroese'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'fr'; Name: 'French'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'fr-BE'; Name: 'French (Belgium)'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'fr-CA'; Name: 'French (Canada)'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'fr-CH'; Name: 'French (Switzerland)'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'fr-FR'; Name: 'French (France)'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'fr-LU'; Name: 'French (Luxembourg)'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'fr-MC'; Name: 'French (Monaco)'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'fy'; Name: 'Western Frisian'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ga'; Name: 'Irish'; PluralForms: 'nplurals=5; plural=n==1 ? 0 : n==2 ? 1 : n>=3 && n<=6 ? 2 : n>=7 && n<=10 ? 3 : 4;'),
    (Code: 'gd'; Name: 'Gaelic; Scottish Gaelic';
    PluralForms: 'nplurals=4; plural=n==1 || n==11 ? 0 : n==2 || n==12 ? 1 : n>=3 && n<=10 || n>=13 && n<=19 ? 2 : 3;'),
    (Code: 'gl'; Name: 'Galician'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'gn'; Name: 'Guarani'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'gu'; Name: 'Gujarati'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'gv'; Name: 'Manx'; PluralForms:
    'nplurals=4; plural=n%10==1 ? 0 : n%10==2 ? 1 : n%100==0 || n%100==20 || n%100==40 || n%100==60 || n%100==80 ? 2 : 3;'),
    (Code: 'ha'; Name: 'Hausa'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'he'; Name: 'Hebrew'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'hi'; Name: 'Hindi'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'ho'; Name: 'Hiri Motu'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'hr'; Name: 'Croatian'; PluralForms:
    'nplurals=3; plural=n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<12 || n%100>14) ? 1 : 2;'),
    (Code: 'hr-BA'; Name: 'Croatian (Bosnia and Herzegovina)';
    PluralForms: 'nplurals=3; plural=n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<12 || n%100>14) ? 1 : 2;'),
    (Code: 'hr-HR'; Name: 'Croatian (Croatia)';
    PluralForms: 'nplurals=3; plural=n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<12 || n%100>14) ? 1 : 2;'),
    (Code: 'ht'; Name: 'Haitian; Haitian Creole'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'hu'; Name: 'Hungarian'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'hy'; Name: 'Armenian'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'hz'; Name: 'Herero'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ia'; Name: 'Interlingua'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'id'; Name: 'Indonesian'; PluralForms: 'nplurals=1; plural=0;'),
    (Code: 'ie'; Name: 'Interlingue; Occidental'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ig'; Name: 'Igbo'; PluralForms: 'nplurals=1; plural=0;'),
    (Code: 'ii'; Name: 'Sichuan Yi; Nuosu'; PluralForms: 'nplurals=1; plural=0;'),
    (Code: 'ik'; Name: 'Inupiaq'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'io'; Name: 'Ido'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'is'; Name: 'Icelandic'; PluralForms: 'nplurals=2; plural=n%10!=1 || n%100==11;'),
    (Code: 'it'; Name: 'Italian'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'it-CH'; Name: 'Italian (Switzerland)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'it-IT'; Name: 'Italian (Italy)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'iu'; Name: 'Inuktitut'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ja'; Name: 'Japanese'; PluralForms: 'nplurals=1; plural=0;'),
    (Code: 'jv'; Name: 'Javanese'; PluralForms: 'nplurals=1; plural=0;'),
    (Code: 'ka'; Name: 'Georgian'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'kg'; Name: 'Kongo'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ki'; Name: 'Kikuyu; Gikuyu'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'kj'; Name: 'Kuanyama; Kwanyama'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'kk'; Name: 'Kazakh'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'kl'; Name: 'Kalaallisut; Greenlandic'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'km'; Name: 'Central Khmer'; PluralForms: 'nplurals=1; plural=0;'),
    (Code: 'kn'; Name: 'Kannada'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'ko'; Name: 'Korean'; PluralForms: 'nplurals=1; plural=0;'),
    (Code: 'kr'; Name: 'Kanuri'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ks'; Name: 'Kashmiri'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ku'; Name: 'Kurdish'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'kv'; Name: 'Komi'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'kw'; Name: 'Cornish'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ky'; Name: 'Kirghiz; Kyrgyz'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'la'; Name: 'Latin'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'lb'; Name: 'Luxembourgish; Letzeburgesch'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'lg'; Name: 'Ganda'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'li'; Name: 'Limburgan; Limburger; Limburgish'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ln'; Name: 'Lingala'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'lo'; Name: 'Lao'; PluralForms: 'nplurals=1; plural=0;'),
    (Code: 'lt'; Name: 'Lithuanian'; PluralForms:
    'nplurals=3; plural=(n%10==1 && (n%100<11 || n%100>19)) ? 0 : (n%10>=2 && n%10<=9 && (n%100<11 || n%100>19)) ? 1 : 2;'),
    (Code: 'lu'; Name: 'Luba-Katanga'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'lv'; Name: 'Latvian'; PluralForms: 'nplurals=3; plural=n%10==1 && n%100!=11 ? 0 : n != 0 ? 1 : 2;'),
    (Code: 'mg'; Name: 'Malagasy'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'mh'; Name: 'Marshallese'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'mi'; Name: 'Maori'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'mk'; Name: 'Macedonian'; PluralForms: 'nplurals=2; plural=n%10!=1 || n%100==11;'),
    (Code: 'ml'; Name: 'Malayalam'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'mn'; Name: 'Mongolian'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'mr'; Name: 'Marathi'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ms'; Name: 'Malay'; PluralForms: 'nplurals=1; plural=0;'),
    (Code: 'mt'; Name: 'Maltese'; PluralForms:
    'nplurals=4; plural=n==1 ? 0 : n==0 || n%100>=2 && n%100<=10 ? 1 : n%100>=11 && n%100<=19 ? 2 : 3;'),
    (Code: 'my'; Name: 'Burmese'; PluralForms: 'nplurals=1; plural=0;'),
    (Code: 'na'; Name: 'Nauru'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'nb'; Name: 'Bokmål, Norwegian; Norwegian Bokmål'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'nd'; Name: 'Ndebele, North; North Ndebele'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ne'; Name: 'Nepali'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ng'; Name: 'Ndonga'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'nl'; Name: 'Dutch; Flemish'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'nl-BE'; Name: 'Dutch (Belgium)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'nl-NL'; Name: 'Dutch (Netherlands)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'nn'; Name: 'Norwegian Nynorsk; Nynorsk, Norwegian'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'no'; Name: 'Norwegian'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'nr'; Name: 'Ndebele, South; South Ndebele'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'nv'; Name: 'Navajo; Navaho'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ny'; Name: 'Chichewa; Chewa; Nyanja'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'oc'; Name: 'Occitan (post 1500)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'oj'; Name: 'Ojibwa'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'om'; Name: 'Oromo'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'or'; Name: 'Oriya'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'os'; Name: 'Ossetian; Ossetic'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'pa'; Name: 'Panjabi; Punjabi'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'pi'; Name: 'Pali'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'pl'; Name: 'Polish'; PluralForms: 'nplurals=3; plural=n==1 ? 0 : n%10>=2 && n%10<=4 && (n%100<12 || n%100>14) ? 1 : 2;'),
    (Code: 'ps'; Name: 'Pushto; Pashto'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'pt'; Name: 'Portuguese'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'pt-BR'; Name: 'Portuguese (Brazil)'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'pt-PT'; Name: 'Portuguese (Portugal)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'qu'; Name: 'Quechua'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'rm'; Name: 'Romansh'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'rn'; Name: 'Rundi'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ro'; Name: 'Romanian'; PluralForms: 'nplurals=3; plural=n==1 ? 0 : (n==0 || (n%100 > 0 && n%100 < 20)) ? 1 : 2;'),
    (Code: 'ro-MD'; Name: 'Romanian (Moldova)'; PluralForms: 'nplurals=3; plural=n==1 ? 0 : (n==0 || (n%100 > 0 && n%100 < 20)) ? 1 : 2;'),
    (Code: 'ru'; Name: 'Russian'; PluralForms:
    'nplurals=3; plural=n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<12 || n%100>14) ? 1 : 2;'),
    (Code: 'rw'; Name: 'Kinyarwanda'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'sa'; Name: 'Sanskrit'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'sc'; Name: 'Sardinian'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'sd'; Name: 'Sindhi'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'se'; Name: 'Northern Sami'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'sg'; Name: 'Sango'; PluralForms: 'nplurals=1; plural=0;'),
    (Code: 'si'; Name: 'Sinhala; Sinhalese'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'sk'; Name: 'Slovak'; PluralForms: 'nplurals=3; plural=(n==1) ? 0 : (n>=2 && n<=4) ? 1 : 2;'),
    (Code: 'sl'; Name: 'Slovenian'; PluralForms: 'nplurals=4; plural=n%100==1 ? 0 : n%100==2 ? 1 : n%100==3 || n%100==4 ? 2 : 3;'),
    (Code: 'sm'; Name: 'Samoan'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'sn'; Name: 'Shona'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'so'; Name: 'Somali'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'sq'; Name: 'Albanian'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'sr'; Name: 'Serbian'; PluralForms:
    'nplurals=3; plural=n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<12 || n%100>14) ? 1 : 2;'),
    (Code: 'sr-BA'; Name: 'Serbian (Bosnia and Herzegovina)';
    PluralForms: 'nplurals=3; plural=n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<12 || n%100>14) ? 1 : 2;'),
    (Code: 'sr-RS'; Name: 'Serbian (Serbia)';
    PluralForms: 'nplurals=3; plural=n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<12 || n%100>14) ? 1 : 2;'),
    (Code: 'ss'; Name: 'Swati'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'st'; Name: 'Sotho, Southern'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'su'; Name: 'Sundanese'; PluralForms: 'nplurals=1; plural=0;'),
    (Code: 'sv'; Name: 'Swedish'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'sv-FI'; Name: 'Swedish (Finland)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'sv-SE'; Name: 'Swedish (Sweden)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'sw'; Name: 'Swahili'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ta'; Name: 'Tamil'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ta-IN'; Name: 'Tamil (India)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ta-LK'; Name: 'Tamil (Sri Lanka)'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'te'; Name: 'Telugu'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'tg'; Name: 'Tajik'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'th'; Name: 'Thai'; PluralForms: 'nplurals=1; plural=0;'),
    (Code: 'ti'; Name: 'Tigrinya'; PluralForms: 'nplurals=2; plural=n > 1;'),
    (Code: 'tk'; Name: 'Turkmen'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'tl'; Name: 'Tagalog'; PluralForms: 'nplurals=2; plural=n != 1 && n != 2 && n != 3 && (n%10==4 || n%10==6 || n%10==9);'),
    (Code: 'tn'; Name: 'Tswana'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'to'; Name: 'Tonga (Tonga Islands)'; PluralForms: 'nplurals=1; plural=0;'),
    (Code: 'tr'; Name: 'Turkish'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ts'; Name: 'Tsonga'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'tt'; Name: 'Tatar'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'tw'; Name: 'Twi'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ty'; Name: 'Tahitian'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'ug'; Name: 'Uighur; Uyghur'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'uk'; Name: 'Ukrainian'; PluralForms:
    'nplurals=3; plural=n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<12 || n%100>14) ? 1 : 2;'),
    (Code: 'ur'; Name: 'Urdu'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'uz'; Name: 'Uzbek'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 've'; Name: 'Venda'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'vi'; Name: 'Vietnamese'; PluralForms: 'nplurals=1; plural=0;'),
    (Code: 'vo'; Name: 'Volapük'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'wa'; Name: 'Walloon'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'wo'; Name: 'Wolof'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'xh'; Name: 'Xhosa'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'yi'; Name: 'Yiddish'; PluralForms: 'nplurals=2; plural=n != 1;'),
    (Code: 'yo'; Name: 'Yoruba'; PluralForms: 'nplurals=1; plural=0;'),
    (Code: 'za'; Name: 'Zhuang; Chuang'; PluralForms: 'nplurals=1; plural=0;'),
    (Code: 'zh'; Name: 'Chinese'; PluralForms: 'nplurals=1; plural=0;'),
    (Code: 'zh-CN'; Name: 'Chinese (Simplified, China)'; PluralForms: 'nplurals=1; plural=0;'),
    (Code: 'zh-HK'; Name: 'Chinese (Traditional, Hong Kong)'; PluralForms: 'nplurals=1; plural=0;'),
    (Code: 'zh-MO'; Name: 'Chinese (Traditional, Macao)'; PluralForms: 'nplurals=1; plural=0;'),
    (Code: 'zh-SG'; Name: 'Chinese (Simplified, Singapore)'; PluralForms: 'nplurals=1; plural=0;'),
    (Code: 'zh-TW'; Name: 'Chinese (Traditional, Taiwan)'; PluralForms: 'nplurals=1; plural=0;'),
    (Code: 'zu'; Name: 'Zulu'; PluralForms: 'nplurals=2; plural=n > 1;')
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

function GetLanguagePluralForms(const ACode: string): string;
var
  I: integer = 0;
  TargetCode: string = '';
begin
  Result := '';
  TargetCode := LowerCase(Trim(ACode));
  for I := Low(Languages) to High(Languages) do
    if LowerCase(Languages[I].Code) = TargetCode then
    begin
      Result := Languages[I].PluralForms;
      Break;
    end;
end;

procedure GetAllPluralForms(AList: TStrings);
var
  I: integer;
  Value: string;
begin
  if AList = nil then
    Exit;
  AList.BeginUpdate;
  try
    AList.Clear;
    for I := Low(Languages) to High(Languages) do
    begin
      Value := Languages[I].PluralForms;
      if (Value <> '') and (AList.IndexOf(Value) < 0) then
        AList.Add(Value);
    end;
  finally
    AList.EndUpdate;
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
