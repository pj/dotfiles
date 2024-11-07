
export type KeyProps = {
    text: string
}
export function Key(props: KeyProps) {
    return (
        <div className="border border-gray-600 rounded-md p-1 text-xs bg-gray-700 text-white h-6 w-6 flex items-center justify-center">
            {props.text}
        </div>
        // <svg 
        // width="1.4rem" height="1.4rem" 
        // version="1.1" viewBox="0 0 103.29 103.68" xmlns="http://www.w3.org/2000/svg" xmlnsXlink="http://www.w3.org/1999/xlink">
        //     <defs>
        //         <linearGradient id="linearGradient30" x1="58.777" x2="67.405" y1="151.52" y2="153.66" gradientUnits="userSpaceOnUse">
        //             <stop stop-color="#343434" offset="0" />
        //             <stop offset="1" />
        //         </linearGradient>
        //         <linearGradient id="linearGradient31" x1="48.826" x2="55.67" y1="155.13" y2="147.65" gradientTransform="matrix(.85206 -.016844 -.013933 -1.0301 111.13 216.27)" gradientUnits="userSpaceOnUse">
        //             <stop stop-color="#323232" offset="0" />
        //             <stop offset="1" />
        //         </linearGradient>
        //         <filter id="filter162" x="-.0023574" y="-.0037234" width="1.0047" height="1.0074" color-interpolation-filters="sRGB">
        //             <feGaussianBlur stdDeviation="0.014015423" />
        //         </filter>
        //         <filter id="filter163" x="-.0029462" y="-.0029462" width="1.0059" height="1.0059" color-interpolation-filters="sRGB">
        //             <feGaussianBlur stdDeviation="0.12275789" />
        //         </filter>
        //         <filter id="filter164" x="-.0079462" y="-.0079462" width="1.0159" height="1.0159" color-interpolation-filters="sRGB">
        //             <feGaussianBlur stdDeviation="0.12275789" />
        //         </filter>
        //         <filter id="filter165" x="-.0045864" y="-.0022314" width="1.0092" height="1.0045" color-interpolation-filters="sRGB">
        //             <feGaussianBlur stdDeviation="0.012120105" />
        //         </filter>
        //     </defs>
        //     <g transform="translate(-49.708 -49.708)">
        //         <path transform="translate(2.7087 3.0916)" x="50" y="50" width="100" height="100" d="m55 50h79.969a15.031 15.031 45 0 1 15.031 15.031v69.926a15.043 15.043 135 0 1-15.043 15.043h-70.386a14.571 14.571 45 0 1-14.571-14.571v-80.429a5 5 135 0 1 5-5z" filter="url(#filter163)" />
        //     </g>
        //     <g transform="translate(-49.708 -49.708)">
        //         <path transform="matrix(.99011 0 0 .99009 .98947 .99071)" x="50" y="50" width="100" height="100" d="m64.851 50h70.673a14.476 14.476 45 0 1 14.476 14.476v70.884a14.64 14.64 135 0 1-14.64 14.64h-70.613a14.748 14.748 45 0 1-14.748-14.748v-70.401a14.851 14.851 135 0 1 14.851-14.851z" fill="#262626" filter="url(#filter164)" stroke="#333" />
        //         <path d="m146.27 54.96 3.2326 3.7675c0.93378 1.0883 3.1675 5.1032 3.1085 9.2686l-2.5925-0.02471c0.12248-8.4092-1.7872-9.7024-3.7486-13.011z" fill="url(#linearGradient31)" filter="url(#filter165)" 
        //         // style="mix-blend-mode:normal" 
        //         />
        //         <path d="m53.02 143.92 1.7257 2.4697c0.93993 1.3452 4.7134 6.7593 12.543 6.5588l-0.06127-2.9294c-7.6667 0.016-11.221-3.4493-14.207-6.0992z" fill="url(#linearGradient30)" filter="url(#filter162)" 
        //         // style="mix-blend-mode:normal" 
        //         />
        //         <text 
        //             x="81.904602" y="120.07066" fill="#262626" 
        //             font-family="'Helvetica Neue'" font-size="56.444px" stroke="#333333" stroke-width=".1"
        //             // style="font-variant-caps:normal;font-variant-east-asian:normal;font-variant-ligatures:normal;font-variant-numeric:normal"
        //             xmlSpace="preserve">
        //             <tspan x="81.904602" y="120.07066"
        //                 fill="#e1e1e1" font-family="'Helvetica Neue'" font-size="56.444px" stroke-width=".1"
        //                 // style="font-variant-caps:normal;font-variant-east-asian:normal;font-variant-ligatures:normal;font-variant-numeric:normal"
        //                 >{props.text}
        //             </tspan></text>
        //     </g>
        // </svg>
    )
}