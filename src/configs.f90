module configs

    use stdlib_sorting, only: sort

    implicit none
    private

    real(8), parameter :: kv = 0.073 ! 14.6% in total, half paid by employer = 7.3%
    real(8), parameter :: pv_outside_sachsen = 0.01525 ! 3.05 % in total, half paid by employer = 1.525% outside of Sachsen
    real(8), parameter :: pv_in_sachsen      = 0.01025 ! 3.05 % in total, employer = 1.025% when in Sachsen
    real(8), parameter :: rv = 0.093 ! 18.6% in total, half paid by employer = 9.3%
    real(8), parameter :: av = 0.012 ! 2.4% in total, half paid by employer = 1.2%
    real(8), parameter :: u3_2022 = 0.0009 ! statutory 0.09% in 2022
    real(8), parameter :: u3_2023 = 0.0015 ! statutory 0.15% in 2023

    public :: t_contribution_levels
    public :: all_bundeslands
    public :: get_contributions
    public :: western

    type :: t_contribution_levels
        character(50) :: bundesland
        real(8) :: kv, kv_personal, &
                   pv, rv, av, &
                   u1, u2, u3
    end type

contains

    pure character(1000) function all_bundeslands() result(output)
        ! The dimension here isn't optimal but list of Bundelands is the
        ! least variable setting in this program.
        ! --------------------------------------------------------------
        character(50), dimension(17) :: arr
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

    pure type(t_contribution_levels) function get_contributions(personal, u1p, u2p, year, bundesland)
        ! This function initializes social insurance contribution levels.
        ! KV, PV, RV and AV are 50% covered by employers, except of RV in Sachsen whenre employer pays little bit less.
        real(8), intent(in) :: personal, u1p, u2p
        integer(4), intent(in) :: year
        character(50), intent(in) :: bundesland

        get_contributions%bundesland = bundesland
        get_contributions%kv = kv
        get_contributions%kv_personal = personal / 2. / 100.
        get_contributions%pv = pv_outside_sachsen
        get_contributions%rv = rv

        get_contributions%av = av 
        if (bundesland == 'Sachsen') then
            get_contributions%pv = pv_in_sachsen
        end if

        ! these depend on the Krankenkasse
        get_contributions%u1 = u1p / 100.
        get_contributions%u2 = u2p / 100.

        ! Insolvenz is statutory
        get_contributions%u3 = u3_2022
        if (year >= 2023) then
            get_contributions%u3 = u3_2023
        end if
        
    end function get_contributions

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