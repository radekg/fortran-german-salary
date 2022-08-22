# German gross salary employer contributions calculator

Calculates German salary employer contributions for a gross number.

## Why

I wanted to write something in Fortran ages ago. As I was reading about [Flang](https://flang.llvm.org/docs/), I got curious. So, there we are. Some reasonable thing Fortran...

## Getting Fortran and fpm on macOS

GFortran comes with `gcc`, so on macOS it is going to be enough. `fpm` is the [Fortram package manager](https://fpm.fortran-lang.org/).

```sh
# This is important, the fpm Formulae uses latest gcc, which right now is 12.
# But that's not going to work because fpm expects that the latest gcc is 11...
# It's a bit of a mess. First, install fpm...
brew tap awvwgk/fpm
brew install fpm
```

Now, fix the gcc story:

```sh
brew install gcc@11
# this is a link:
rm /usr/local/opt/gcc
# fix the link
ln /usr/local/Cellar/gcc\@11/11.3.0 /usr/local/opt/gcc
ln /usr/local/Cellar/gcc\@11/11.3.0/lib/gcc/11 /usr/local/Cellar/gcc\@11/11.3.0/lib/gcc/current
```

Now fpm will work.

## Build

Check out the project and build it:

```sh
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

## Assumptions

This program assumes `Individueller Zusatzbeitragssatz` at `0.6%` (half of the usually referenced Krankenkasse contribution, in this case TK for 2022: `1.2%`).

## Where do I get some more info about these calculation?

You can find all important information [here]:

- [For 2022](https://www.lohn-info.de/sozialversicherungsbeitraege2022.html).
- [For 2023](https://www.lohn-info.de/sozialversicherungsbeitraege2023.html).
