import DataPlot
import example
import wx
from wx import xrc



class G3App(wx.App):

    def OnInit(self):

        # Load the XML resource file
        self.res = xrc.XmlResource('G3.xrc')

        # Declare objects for each part of the gui,
        # we fetch the objects from the loaded XML resource
        # via the name we gave each component in the builder.
        self.frame = self.res.LoadFrame(None, 'mainFrame')
        self.runButton = xrc.XRCCTRL(self.frame, 'runButton')
        self.durationTextCtrl = xrc.XRCCTRL(self.frame,'durationTextCtrl')

        # Bind the gui objects to methods.
        #
        # Note: frame is the main component inthe MainLoop so this
        # is what we set the binding to. 
        self.frame.Bind(wx.EVT_BUTTON, self.OnRun, self.runButton)

        # Display our simple gui.
        self.frame.Show()
        return True       


    # An action to do when the run button is pushed.
    # This will run the simulation with the given time
    # and plot the output.
    def OnRun(self,evt):

        simulation_time = float(self.durationTextCtrl.GetValue())
        print "Simulation time is: " + str(simulation_time)
        print "running simulation..."

        example.run_simulation(simulation_time)

        print "Simulation Complete!"

        print "Plotting output"
        self.Plot('/tmp/output')


    ##
    # Plots data output from a data file.
    #
    #wxPython sizer & layouts
    # This is the alternative to using an
    # XRC specification, this however is a small
    # example.
    def Plot(self,datafile):

        plotwindow = wx.Frame(self.frame, -1, "Graph display", (480,300))
        plotpanel = wx.Panel(plotwindow, -1)

        self.dataplot = DataPlot.DataPlot(plotpanel, -1,
                                          '/tmp/output',
                                          'Example Plot',
                                          'Time (Seconds)',
                                          'Membrane Potential (Volts)')

        vbox_sizer = wx.BoxSizer(wx.VERTICAL)
        vbox_sizer.Add(self.dataplot, 1, wx.EXPAND)
        plotpanel.SetAutoLayout(True)
        plotpanel.SetSizer(vbox_sizer)
        plotpanel.Layout()
        plotwindow.Show()



# Our main function where we perform our main loop
if __name__ == '__main__':
    app = G3App(False)
    app.MainLoop()




