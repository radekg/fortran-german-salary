# German gross salary employer contributions calculator

Calculates German salary employer contributions for a gross number.

This program does not calculate employee contributions breakdown, only the employer part.

## Why

I wanted to write something in Fortran ages ago. As I was reading about [Flang](https://flang.llvm.org/docs/), I got curious. So, there we are. Some reasonable thing for Fortran...

## Getting Fortran and fpm on macOS

GFortran comes with `gcc`, so on macOS it is going to be enough. `fpm` is the [Fortram package manager](https://fpm.fortran-lang.org/).

```sh
# This is important, the fpm Formulae uses latest gcc, which right now is 12.
# But that's not going to work because fpm expects that the latest gcc is 11...
# It's a bit of a mess. First, install fpm...
brew tap awvwgk/fpm
brew install fpm
```

Now, fix the `gcc` story:

```sh
brew install gcc@11
# this is a link:
rm /usr/local/opt/gcc
# fix the link
ln /usr/local/Cellar/gcc\@11/11.3.0 /usr/local/opt/gcc
ln /usr/local/Cellar/gcc\@11/11.3.0/lib/gcc/11 /usr/local/Cellar/gcc\@11/11.3.0/lib/gcc/current
```

`fpm` will work now.

## Build

Check out the project and build it:

```sh
git clone https://github.com/radekg/fortran-german-salary.git
cd fortran-german-salary/
fpm install
```

## Examples

Gross annual €75k, 12 salaries:

```sh
~/.local/bin/german_salary --gross 75000
```

Gross monthly €6.1k, 12 salaries:

```sh
~/.local/bin/german_salary --gross 6100 --mode month
```

Gross monthly €6.1k, 14 salaries:

```sh
~/.local/bin/german_salary --gross 6100 --salaries 14 --mode month
```

Gross annual €75k, 13 salaries, Sachsen:

```sh
~/.local/bin/german_salary --gross 75000 --salaries 13 --bundesland Sachsen
```

## Output

This program produces human readable output only, example:

```

Bundesland:                       Nordrhein-Westfalen
West/East:                        West
Currency:                         Euro
Monthly gross salary:                6100.00
Annual gross salary:                85400.00
# of salaries:                          14.0
--------------------------------------------|
Contributions breakdown:
  Kranenversicherung:                5350.27
  Pflegeversicherung:                1032.81
  Rentenversicherung:                7942.20
  Arbeitslosenversicherung:          1024.80
--------------------------------------------|
Umlagen:
  U1 (Arbeitsunfähigkeit):           1366.40
  U2 (Mutterschaft):                  555.10
  U3 (Insolvenz):                      76.86
--------------------------------------------|
Total annual cost:                 102748.44

```

## CLI options

Required switches:

- `--gross value`, `-g value`: Gross salary

Optional switches:

- `--mode value`, `-m value`, value in: `annum,month`, default value `annum`: Gross salary mode
- `--salaries value`, `-s value`, value in: `12.0,13.0,14.0`, default value `12.0`: Number of salaries
- `--bundesland value`, `-b value`, value in: `Baden-Württemberg,Bayern,Berlin-Ost,Berlin-West,Brandenburg,Bremen,Hamburg,Hessen,Mecklenburg-Vorpommern,Niedersachsen,Nordrhein-Westfalen,Rheinland-Pfalz,Saarland,Sachsen,Sachsen-Anhalt,Schleswig-Holstein,Thüringen`, default value `Nordrhein-Westfalen`: Bundesland
- `--year value`, `-yr value`, value in: `2022,2023`, default value `2023`: Year for which the calculation should be done
- `--kv-personal-contribution-percent value`, `-kvp value`, default value `1.2`: Personal health insurance contribution, in total percentage
- `--u1-contribution-percent value`, `-u1 value`, default value `1.6`: The work incapacity protection contribution, in total percent (U1)
- `--u2-contribution-percent value`, `-u2 value`, default value `0.65`: The maternity protection contribution, in total percent (U2)
- `--help`, `-h`: Print this help message
- `--version`, `-v`: Print version

## German social insurance for employers in a nutshell

Given a gross salary, in 2023:

- Krankenversicherung is `14.6%` from which the employer pays half = `7.3%`, employee pays the other half.
  - An employee contributes _individual additional contribution rate_ (_Individueller Zusatzbeitragssatz_) which depends on the Krankenkasse they belong to. In case of TK, this is `1.6%` from which the employer pays half, the employee pays the other half.
  - Total Krankenversicherung paid by the employer accounts to `7.3%` + `0.8%` for an employee in TK.
  - Calculated based on a single gross salary with a top limit of `€4837.5` - `min(€4837.5, single gross salary) * rate`.
- Pflegeversicherung is `3.05%`.
  - In Sachsen, employer pays `1.025%`, employee pays `2.025%`.
  - Outside of Sachsen, employer pays half = `1.525%`, employee pays the other half.
  - Calculated based on a single gross salary with a top limit of `€4837.5` - `min(€4837.5, single gross salary) * rate`.
- Rentenversicherung is `18.6%` from which the employer pays half = `9.3%`, the employee pays the other half.
  - Calculated based on a single gross salary with a top limit of:
    - Western Bundesland: `€7050` - `min(€7050, single gross salary) * rate`,
    - Eastern Bundesland: `€6750` - `min(€6750, single gross salary) * rate`.
- Arbeitslosenversicherung is `2.4%` from which the employer pays half = `1.2%`, the employee pays the other half.
  - Calculated based on a single gross salary with a top limit of:
    - Western Bundesland: `€7050` - `min(€7050, single gross salary) * rate`,
    - Eastern Bundesland: `€6750` - `min(€6750, single gross salary) * rate`.

- Umlage 1 (Arbeitsunfähigkeit) depends on the Krankenkasse of the employee, for TK this value is `1.6%` for standard reimbursement rate of `70%`.
- Umlage 2 (Mutterschaft) depends on the Krankenkasse of the employee, for TK this value is `0.65%`.
- Umlage 3 (Insolvenz) is statutory and in 2023 will be `0.15%`, the employer pays the full amount.

### Single gross salary

I use this term instead of _monthly gross salary_ because in Germany:

- An employee receives statutory 12 salaries.
- An  employer may decide to pay 13th and 14th salary.
  - In this case, the _single gross salary_ is calculated simply by diving annual gross salary / number of salaries. For example, an employee at `€75000` gross / annum implies:
    - `€6250` at 12 salaries,
    - `€5769.23` at 13 salaries (13th salary paid either in July or November),
    - `€5357.14` at 14 salaries (usually 13th salary paid in July, 14th salary in November).

Any other variable like: age, number of children, any additional pension fund, does not affect employer's contributions, only employee's net income.

## Where do I find the latest numbers?

You can find all important information [here](https://www.lohn-info.de/):

- [For 2022](https://www.lohn-info.de/sozialversicherungsbeitraege2022.html).
- [For 2023](https://www.lohn-info.de/sozialversicherungsbeitraege2023.html).

The U1 and U2 values are health insurance provider specific. For the exact values of a specific Krankenkasse, consult their websites. For example:

- [TK: Wie hoch sind die Umla­ge­sätze U1 und U2?](https://www.tk.de/firmenkunden/versicherung/beitraege-faq/umlagen-u1-u2-und-insolvenzgeld/hoehe-umlagesaetze-u1-und-u2-2031720)
