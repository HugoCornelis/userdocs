import sys
sys.path.append('/usr/local/glue/swig/python')
import wx
from wx import xrc

# global for simulation time
simulation_time = 0.0

class G3App(wx.App):

    def OnInit(self):

        # Load the XML resource file
        self.res = xrc.XmlResource('G3.xrc')

        # Declare objects for each part of the gui,
        # we fetch the objects from the loaded XML resource
        # via the name we gave each component in the builder.
        self.frame = self.res.LoadFrame(None, 'mainFrame')
        self.runButton = xrc.XRCCTRL(self.frame, 'runButton')
        self.setButton = xrc.XRCCTRL(self.frame, 'setButton')
        self.durationTextCtrl = xrc.XRCCTRL(self.frame,'durationTextCtrl')

        # Bind the gui objects to methods.
        #
        # Note: frame is the main component inthe MainLoop so this
        # is what we set the binding to. 
        self.frame.Bind(wx.EVT_BUTTON, self.OnRun, self.runButton)
        self.frame.Bind(wx.EVT_BUTTON, self.OnSet, self.setButton)

        # Display our simple gui.
        self.frame.Show()
        return True

    # An action to do when the setup button is pushed.
    def OnSet(self, evt):
        global simulation_time
        simulation_time = float(self.durationTextCtrl.GetValue())
        print "Simulation time set to " + self.durationTextCtrl.GetValue() + "\n\n"
       

    # An action to do when the run button is pushed.
    def OnRun(self,evt):
        global simulation_time
        print "Simulation time is: " + str(simulation_time)
        print "run simulation..."
        # here we would do
        #
        # run_simulation(simulation_time)



# Our main function where we perform our main loop
if __name__ == '__main__':
    app = G3App(False)
    app.MainLoop()

