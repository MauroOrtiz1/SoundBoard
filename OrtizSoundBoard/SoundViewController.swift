//
//  SoundViewController.swift
//  OrtizSoundBoard
//
//  Created by mauro on 10/8/24.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {
    
    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    @IBOutlet weak var timertLabel: UILabel!
    @IBOutlet weak var volumenSlider: UISlider!
    
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    var timer: Timer?
    var timeElapsed: TimeInterval = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
    }
    
    func configurarGrabacion() {
        do {
            // creando sesion de audio
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)

            // creando direccion para el archivo de audio
            let basePath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!

            // impresion de ruta donde se guardan los archivos
            print("*******************")
            print(audioURL!)
            print("*******************")

            // crear opciones para el grabador de audio
            var settings: [String: AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?

            // crear el objeto de grabacion de audio
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()

        } catch let error as NSError {
            print(error)
        }
    }
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording {
            // detener la grabacion y el timer
            grabarAudio?.stop()
            timer?.invalidate()
            // cambiar texto del botón grabar
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
        } else {
            // empezar a grabar
            grabarAudio?.record()
            timeElapsed = 0.0 // Resetear el tiempo
            //timertLabel.text = "Tiempo: 0s"
            startTimer()
            // cambiar el texto del botón grabar a detener
            grabarButton.setTitle("DETENER", for: .normal)
            reproducirButton.isEnabled = false
            //agregarButton.isEnabled = false
        }
    }
    @IBAction func reproducirTapped(_ sender: Any) {
        do {
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            print("Reproduciendo")
        } catch {}
    }
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        grabacion.tiempo = Int16(timeElapsed)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
    @IBAction func volumenChanged(_ sender: UISlider) {
        reproducirAudio?.volume = sender.value
    }
    
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.timeElapsed += 1.0
            self.timertLabel.text = "Tiempo: \(Int(self.timeElapsed))s"
        }
    }
}
