import sys
import os
import pdb
import wx
import wx.lib.plot as plot


##
#
#
class DataPlot(plot.PlotCanvas):


    ##
    #
    #
    def __init__(self,parent,id,data,plottitle,xtitle,ytitle):

        # store the parent object into a class member.
        self.parent = parent
        
        plot.PlotCanvas.__init__(self,parent,id=-1)

        self.SetEnableZoom(True)
        
        self.lines = self.LoadData(data)
        
        gc = plot.PlotGraphics(self.lines,plottitle,xtitle,ytitle)
        self.Draw(gc)


    ##
    #
    #
    def SetTitle(self,title):

        if title == None:
            return

        if title == "":
            return
        
        self.PlotTitle = title

    ##
    #
    #
    def SetXTitle(self,xtitle):
        if xtitle == None:
            return

        if xtitle == "":
            return
        
        self.PlotTitle = xtitle


    ##
    #
    #
    def SetYTitle(self,ytitle):
        if ytitle == None:
            return

        if ytitle == "":
            return
        
        self.PlotTitle = ytitle



    ##
    # parses and  returns lines.
    #
    def LoadData(self,datafile):
        if os.path.exists(datafile) and os.path.isfile(datafile):
            f=open(datafile,'r')
            datatext=f.readlines()

            numcolumns = len(datatext[0].split())

            xvalues= self.GetColumn(datatext,0)
            lines = []
            for i in range(1,numcolumns):
                yvalues = self.GetColumn(datatext,i)
                currentline = self.GetLine(xvalues,yvalues)
                lines.append(currentline)

            return lines
            
        else:
            return None

    ##
    # returns a column of the text file as a list
    #
    def GetColumn(self,datalines,colnum):

        column = []
        for line in datalines:
            line.rstrip('\n')
            a = line.split()
            column.append(float(a[colnum]))

        return column

    ##
    #
    def GetLine(self,x,y):
        points = []

        for i in range(len(x)):
            points.append((x[i],y[i]))

        line = plot.PolyLine(points, colour='black', width=1)
        return line



##
#
#
class DataPlotTest(wx.Frame):
   def __init__(self):
      wx.Frame.__init__(self, None, id=-1, title="Graph display", size=(480,300))
      main_panel = wx.Panel(self, -1)


      self.plot_window = DataPlot(main_panel, -1,'/tmp/output','Example','Time (Seconds)','Membrane Potential (Volts)')


      #sizer & layouts
      vbox_sizer = wx.BoxSizer(wx.VERTICAL)
      vbox_sizer.Add(self.plot_window, 1, wx.EXPAND|wx.ALIGN_LEFT)
      main_panel.SetAutoLayout(True)
      main_panel.SetSizer(vbox_sizer)
      main_panel.Layout()


if __name__ == '__main__':
    app = wx.App(0)
    dataplot = DataPlotTest()
    dataplot.Show()
    app.MainLoop()
