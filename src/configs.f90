module configs

    use stdlib_sorting, only: sort

    implicit none
    private

    public :: all_bundeslands
    public :: western
contains

    pure function all_bundeslands() result(output)
        ! The dimension here isn't optimal but list of Bundelands is the
        ! least variable setting in this program.
        ! --------------------------------------------------------------
        character(50), dimension(17) :: arr
        character(1000) :: output
        integer(4) :: i
        ! merge arrays
        ! ------------
        arr(1:11) = western()
        arr(12:) = eastern()
        ! then sort the resulting array
        ! -----------------------------
        call sort(arr)
        ! and join individual items with commas
        ! -------------------------------------
        output = trim(arr(1)) ! initialize the string, data is garbled if we don't do this...
        do i=2, size(arr), 1
            output = trim(output) // ',' // trim(arr(i))
        end do
    end function all_bundeslands

    pure function western() result(out)
        character(50), dimension(11) :: out !< There are 11 Western Bundeslands.
        out = [ character(50) :: 'Baden-Württemberg', &
            'Bayern', &
            'Berlin-West', &
            'Bremen', &
            'Hamburg', &
            'Hessen', &
            'Niedersachsen', &
            'Nordrhein-Westfalen', &
            'Rheinland-Pfalz', &
            'Saarland', &
            'Schleswig-Holstein' ]
    end function western

    pure function eastern() result(out)
        character(50), dimension(6) :: out !< There are 6 Eastern Bundeslands.
        out = [ character(50) :: 'Berlin-Ost', &
            'Brandenburg', &
            'Mecklenburg-Vorpommern', &
            'Sachsen', &
            'Sachsen-Anhalt', &
            'Thüringen' ]
    end function eastern



end module configs