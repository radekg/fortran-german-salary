!< This program calculates German salary employer contributions.
program main

    use flap,       only : command_line_interface
    use calculator, only: SalaryCalculator
    use types,      only: all_bundeslands, Bundesland, ContributionsParams, ContributionLevels
    use utils,      only: make_label

    implicit none

    type(command_line_interface) :: cli ! Command Line Interface (CLI).
    real(8)                      :: input_gross,        &
                                    input_kv_personal,  &
                                    input_u1,           &
                                    input_u2
    integer(4)                   :: input_year, input_salaries
    character(5)                 :: input_gross_mode
    character(50)                :: input_bundesland
    integer                      :: error  ! Error trapping flag.
    type(ContributionLevels)     :: contributions
    type(SalaryCalculator)       :: salary_calculator

    ! init CLI
    call cli%init(description = 'Calculate employer contributions for gross salary')

    ! init flags
    call cli%add(switch='--gross',  &
        switch_ab='-g',             &
        help='Gross salary',        &
        required=.true.,            &
        act='store',                &
        error=error)
    call cli%add(switch='--mode',   &
        switch_ab='-m',             &
        help='Gross salary mode',   &
        required=.false.,           &
        act='store',                &
        def='annum',                &
        choices='annum,month',      &
        error=error)
    call cli%add(switch='--salaries',   &
        switch_ab='-s',                 &
        help='Number of salaries',      &
        required=.false.,               &
        act='store',                    &
        def='12',                       &
        choices='12,13,14',             &
        error=error)
    call cli%add(switch='--bundesland',     &
        switch_ab='-b', help='Bundesland',  &
        required=.false.,                   &
        act='store',                        &
        def='Nordrhein-Westfalen',          &
        choices=trim(all_bundeslands()),    &
        error=error)
    call cli%add(switch='--year',                               &
        switch_ab='-yr',                                        &
        help='Year for which the calculation should be done',   &
        required=.false.,                                       &
        act='store',                                            &
        def='2023',                                             &
        choices='2022,2023',                                    &
        error=error)
    call cli%add(switch='--kv-personal-contribution-percent',               &
        switch_ab='-kvp',                                                   &
        help='Personal health insurance contribution, in total percentage', &
        required=.false.,                                                   &
        act='store',                                                        &
        def='1.2',                                                          &
        error=error)
    call cli%add(switch='--u1-contribution-percent',                                &
        switch_ab='-u1',                                                            &
        help='The work incapacity protection contribution, in total percent (U1)',  &
        required=.false.,                                                           &
        act='store',                                                                &
        def='1.6',                                                                  &
        error=error)
    call cli%add(switch='--u2-contribution-percent',                            &
        switch_ab='-u2',                                                        &
        help='The maternity protection contribution, in total percent (U2)',    &
        required=.false.,                                                       &
        act='store',                                                            &
        def='0.65',                                                             &
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

    contributions = ContributionLevels(              &
        params=ContributionsParams(                  &
            kv_personal=input_kv_personal,           &
            bundesland=Bundesland(input_bundesland), &
            year=input_year,                         &
            u1=input_u1,                             &
            u2=input_u2))

    salary_calculator = SalaryCalculator( &
        contributions=contributions,      &
        gross_value=input_gross,          &
        salaries=input_salaries,          &
        mode=input_gross_mode)

    print '(a)', ''
    print '(a, a)',     make_label('Bundesland'), contributions%params%bundesland%name
    print '(a, a)',     make_label('West/East'), contributions%params%bundesland%region_string()
    print '(a, a)',     make_label('Currency'), 'Euro'
    print '(a, f10.2)', make_label('Monthly gross salary'), salary_calculator%calculated_gross_monthly
    print '(a, f10.2)', make_label('Annual gross salary'), salary_calculator%calculated_gross_annual
    print '(a, i10)', make_label('# of salaries'), salary_calculator%salaries
    print '(a)',       '--------------------------------------------|'
    print '(a)', 'Contributions breakdown:'
    print '(a, f10.2)', make_label('Kranenversicherung', indent=2), salary_calculator%calculated_kv
    print '(a, f10.2)', make_label('Pflegeversicherung', indent=2), salary_calculator%calculated_pv
    print '(a, f10.2)', make_label('Rentenversicherung', indent=2), salary_calculator%calculated_rv
    print '(a, f10.2)', make_label('Arbeitslosenversicherung', indent=2), salary_calculator%calculated_av
    print '(a)',       '--------------------------------------------|'
    print '(a)', 'Umlagen:'
    print '(a, a, f10.2)', make_label('U1 (Arbeitsunfähigkeit)', indent=2), ' ', salary_calculator%calculated_u1 ! extra space because we have an umlaut...
    print '(a, f10.2)',    make_label('U2 (Mutterschaft)', indent=2), salary_calculator%calculated_u2
    print '(a, f10.2)',    make_label('U3 (Insolvenz)', indent=2), salary_calculator%calculated_u3
    print '(a)',       '--------------------------------------------|'

    print '(a, f10.2)', make_label('Total annual employee cost'), salary_calculator%calculated_total
    print '(a)', ''

end program main
