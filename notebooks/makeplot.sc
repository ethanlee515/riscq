import $ivy.`io.github.cibotech::evilplot:0.9.0`
import com.cibo.evilplot.colors.HTMLNamedColors._
import com.cibo.evilplot.numeric.Bounds
import com.cibo.evilplot.plot._
import com.cibo.evilplot.plot.aesthetics.DefaultTheme._
import java.io.File
import java.io.ByteArrayOutputStream
import javax.imageio.ImageIO
import java.util.Base64
import java.nio.file.Files
import com.cibo.evilplot.geometry.Drawable
import scala.collection.mutable.ArrayBuffer

val plot_colors = List(dodgerBlue, tomato, green, purple, black, sienna)

def makefn(data : Seq[Double])(x: Double) : Double = {
    val i = x.toInt
    if (i < 0)
        data.head
    else if (i >= data.length)
        data.last
    else
        data(i)
}

case class LabeledData(label: String, data: Seq[Double])

def make_plot(ys : Seq[LabeledData]) : Array[Byte] = {
    val plots = ArrayBuffer[Plot]()
    for(i <- 0 until ys.length) {
        val LabeledData(label, data) = ys(i)
        plots += FunctionPlot.series(makefn(data), label, plot_colors(i), xbounds = Some(Bounds(0, data.length)))
    }
    val overlay = Overlay(plots : _*).title("Simulation Results")
        .overlayLegend()
        .standard()
        .render()
    val tmpFile: File = Files.createTempFile("evilplot", ".png").toFile
    overlay.write(tmpFile)
    val pngBytes: Array[Byte] = Files.readAllBytes(tmpFile.toPath)
    return pngBytes
}