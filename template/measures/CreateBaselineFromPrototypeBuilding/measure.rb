
# Start the measure
class CreateBaselineFromPrototypeBuilding < OpenStudio::Measure::ModelMeasure

  
  #define the name that a user will see, this method may be deprecated as
  #the display name in PAT comes from the name field in measure.xml
  def name
    return "Create Baseline From Prototype Building"
  end

  #define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Ruleset::OSArgumentVector.new
    
    # Make integer arg to run measure [1 is run, 0 is no run]
    run_measure = OpenStudio::Ruleset::OSArgument::makeIntegerArgument("run_measure",true)
    run_measure.setDisplayName("Run Measure")
    run_measure.setDescription("integer argument to run measure [1 is run, 0 is no run]")
    run_measure.setDefaultValue(1)
    args << run_measure    
    
    return args
  end #end the arguments method

  #define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    #use the built-in error checking 
    if not runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end
    
    # Return N/A if not selected to run
    run_measure = runner.getIntegerArgumentValue("run_measure",user_arguments)
    if run_measure == 0
      runner.registerAsNotApplicable("Run Measure set to #{run_measure}.")
      return true     
    end    
	
    
    runner.registerInfo("Making EMS string for Load Schedules")
    #start making the EMS code
    ems_string = ""  #clear out the ems_string
    
	ems_string << "Schedule:File," + "\n"
    ems_string << "   HeatingLoad,  !- Name" + "\n"
    ems_string << "   Any Number,  !- Schedule Type Limits Name" + "\n"
    ems_string << "   C:/Users/Public/Documents/loads.csv,       !- File Name" + "\n"
    ems_string << "   1,         			!- Column Number" + "\n"
    ems_string << "   1,  					!- Rows to Skip at Top" + "\n"
    ems_string << "   8760,       			!- Number of Hours of Data" + "\n"
    ems_string << "   Comma;        		!- Column Separator" + "\n"	
    ems_string << "\n"
    ems_string << "Schedule:File," + "\n"
    ems_string << "   CoolingLoad,  !- Name" + "\n"
    ems_string << "   Any Number,  !- Schedule Type Limits Name" + "\n"
    ems_string << "   C:/Users/Public/Documents/loads.csv,       !- File Name" + "\n"
    ems_string << "   2,         			!- Column Number" + "\n"
    ems_string << "   1,  					!- Rows to Skip at Top" + "\n"
    ems_string << "   8760,       			!- Number of Hours of Data" + "\n"
    ems_string << "   Comma;        		!- Column Separator" + "\n"	
    ems_string << "\n"
    ems_string << "Output:Variable,CoolingLoad,Schedule Value,Hourly; !- HVAC Average []" + "\n"
    ems_string << "Output:Variable,HeatingLoad,Schedule Value,Hourly; !- HVAC Average []" + "\n"	
	
    #save EMS snippet
    runner.registerInfo("Saving idf schedule loads file")
    FileUtils.mkdir_p(File.dirname("scheduledLoads.ems")) unless Dir.exist?(File.dirname("scheduledLoads.ems"))
    File.open("scheduledLoads.ems", "w") do |f|
      f.write(ems_string)
    end   
	
	#replace_model(model,runner)

    return true
  end
    

end #end the measure

#this allows the measure to be use by the application
CreateBaselineFromPrototypeBuilding.new.registerWithApplication
