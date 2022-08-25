!< This program calculates German salary employer contributions.
program main

    use flap, only : command_line_interface
    use types, only: all_bundeslands, Bundesland, ContributionsParams, &
                     ContributionLevels
    use utils, only: get_annual_gross, get_monthly_gross, make_label, west_east_string
    use calculations, only: calculate_kv, calculate_pv, calculate_rv, calculate_av, &
                            calculate_u1, calculate_u2, calculate_u3

    implicit none

    type(command_line_interface) :: cli ! Command Line Interface (CLI).
    real(8)                      :: input_gross, input_salaries, &
                                    monthly_gross, annual_gross, &
                                    input_kv_personal, input_u1, input_u2
    integer(4)                   :: input_year
    character(5)                 :: input_gross_mode
    character(50)                :: input_bundesland

    integer         :: error  ! Error trapping flag.

    type(ContributionsParams) :: contributions_params
    type(ContributionLevels) :: contributions

    ! define calculation results
    ! TODO: apparently one can do class-like objects in Fortran...
    real(8) :: kv, pv, rv, av, u1, u2, u3, total
    real(8), dimension(8) :: to_sum

    ! init CLI
    call cli%init(description = 'Calculate employer contributions for gross salary')

    ! init flags
    call cli%add(switch='--gross', switch_ab='-g', help='Gross salary', &
                required=.true., &
                act='store',     &
                error=error)
    call cli%add(switch='--mode', switch_ab='-m', help='Gross salary mode', &
                required=.false.,      &
                act='store',           &
                def='annum',           &
                choices='annum,month', &
                error=error)
    call cli%add(switch='--salaries', switch_ab='-s', help='Number of salaries', &
                required=.false.,         &
                act='store',              &
                def='12.0',               &
                choices='12.0,13.0,14.0', &
                error=error)
    call cli%add(switch='--bundesland', switch_ab='-b', help='Bundesland', &
                required=.false.,                &
                act='store',                     &
                def='Nordrhein-Westfalen',       &
                choices=trim(all_bundeslands()), &
                error=error)
    call cli%add(switch='--year', switch_ab='-yr', &
                help='Year for which the calculation should be done', &
                required=.false.,    &
                act='store',         &
                def='2023',          &
                choices='2022,2023', &
                error=error)

    call cli%add(switch='--kv-personal-contribution-percent', switch_ab='-kvp', &
                help='Personal health insurance contribution, in total percentage', &
                required=.false., &
                act='store',      &
                def='1.2',        &
                error=error)
    call cli%add(switch='--u1-contribution-percent', switch_ab='-u1', &
                help='The work incapacity protection contribution, in total percent (U1)', &
                required=.false., &
                act='store',      &
                def='1.6',        &
                error=error)
    call cli%add(switch='--u2-contribution-percent', switch_ab='-u2', &
                help='The maternity protection contribution, in total percent (U2)', &
                required=.false., &
                act='store',      &
                def='0.65',       &
                error=error)
  
    if (error/=0) stop

    ! get data passed on the command line
    call cli%get(switch='-g', val=input_gross, error=error)
    call cli%get(switch='-m', val=input_gross_mode, error=error)
    call cli%get(switch='-s', val=input_salaries, error=error)
    call cli%get(switch='-b', val=input_bundesland, error=error)
    call cli%get(switch='-yr', val=input_year, error=error)
    call cli%get(switch='-kvp', val=input_kv_personal, error=error)
    call cli%get(switch='-u1', val=input_u1, error=error)
    call cli%get(switch='-u2', val=input_u2, error=error)

    if (error/=0) stop

    ! Initialize contributions for the configured year
    contributions_params = ContributionsParams( &
        kv_personal=input_kv_personal,           &
        bundesland=Bundesland(input_bundesland), &
        year=input_year,                         &
        u1=input_u1,                             &
        u2=input_u2)
    contributions = ContributionLevels(params=contributions_params)

    ! Get the annual and monthly salary
    annual_gross = get_annual_gross(input_gross, input_salaries, input_gross_mode)
    monthly_gross = get_monthly_gross(input_gross, input_salaries, input_gross_mode)
    ! Calculate
    kv = calculate_kv(monthly_gross, contributions) * input_salaries
    pv = calculate_pv(monthly_gross, contributions) * input_salaries
    rv = calculate_rv(monthly_gross, contributions) * input_salaries
    av = calculate_av(monthly_gross, contributions) * input_salaries

    u1 = calculate_u1(annual_gross, contributions)
    u2 = calculate_u2(annual_gross, contributions)
    u3 = calculate_u3(annual_gross, contributions)

    print '(a)', ''
    print '(a, a)',     make_label('Bundesland'), contributions%params%bundesland%name
    print '(a, a)',     make_label('West/East'), contributions%params%bundesland%region_string()
    print '(a, a)',     make_label('Currency'), 'Euro'
    print '(a, f10.2)', make_label('Monthly gross salary'), monthly_gross
    print '(a, f10.2)', make_label('Annual gross salary'), annual_gross
    print '(a, f10.1)', make_label('# of salaries'), input_salaries
    print '(a)',       '--------------------------------------------|'
    print '(a)', 'Contributions breakdown:'
    print '(a, f10.2)', make_label('Kranenversicherung', indent=2), kv
    print '(a, f10.2)', make_label('Pflegeversicherung', indent=2), pv
    print '(a, f10.2)', make_label('Rentenversicherung', indent=2), rv
    print '(a, f10.2)', make_label('Arbeitslosenversicherung', indent=2), av
    print '(a)',       '--------------------------------------------|'
    print '(a)', 'Umlagen:'
    print '(a, a, f10.2)', make_label('U1 (Arbeitsunfähigkeit)', indent=2), ' ', u1 ! extra space because we have an umlaut...
    print '(a, f10.2)',    make_label('U2 (Mutterschaft)', indent=2), u2
    print '(a, f10.2)',    make_label('U3 (Insolvenz)', indent=2), u3
    print '(a)',       '--------------------------------------------|'

    to_sum = [ annual_gross, kv, pv, rv, av, u1, u2, u3 ]
    total = sum(to_sum(1: 8))

    print '(a, f10.2)', make_label('Total annual employee cost'), total
    print '(a)', ''

end program main
